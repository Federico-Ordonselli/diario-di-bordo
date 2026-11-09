import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp,readFile,writeFile,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {pathToFileURL} from 'node:url';
import {initialState} from '../src/engine.js';
test('Archivio su disco: lettura condivisa, conflitto, backup e dati invalidi',async()=>{
 const directory=await mkdtemp(tmpdir()+'/kh-profile-');
 try{
  const source=(await readFile(new URL('../profile-server.mjs',import.meta.url),'utf8')).replace("'./src/engine.js'",JSON.stringify(new URL('../src/engine.js',import.meta.url).href)).replace("fileURLToPath(new URL('./data/',import.meta.url))",JSON.stringify(directory+'/'));
  await writeFile(directory+'/api.mjs',source);const {profileApi}=await import(pathToFileURL(directory+'/api.mjs'));
  async function call(method,input){let status,body;const req={url:'/api/profile',method,headers:{'content-type':'application/json'},async *[Symbol.asyncIterator](){yield JSON.stringify(input);}};await profileApi(req,{writeHead(code){status=code;},end(data){body=JSON.parse(data);}},()=>assert.fail());return {status,body};}
  const empty=await call('GET');assert.equal(empty.body.state,null);
  const state=initialState();const first=await call('PUT',{state,revision:null});assert.equal(first.status,200);
  assert.deepEqual((await call('GET')).body.state,state);
  assert.equal((await call('PUT',{state,revision:null})).status,409);
  const next=structuredClone(state);next.inventory.lucid_shard=123;
  assert.equal((await call('PUT',{state:next,revision:first.body.revision,backup:true})).status,200);
  assert.deepEqual(JSON.parse(await readFile(directory+'/before-import.json','utf8')),state);
  assert.equal((await call('PUT',{state:{schemaVersion:999},revision:first.body.revision})).status,500);
  assert.equal((await call('GET')).body.state.inventory.lucid_shard,123);
 }finally{await rm(directory,{recursive:true,force:true});}
});
