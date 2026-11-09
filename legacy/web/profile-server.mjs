import {readFile,mkdir,writeFile,rename} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {validateState} from './src/engine.js';
const directory=fileURLToPath(new URL('./data/',import.meta.url));
const file=directory+'profile.json';
let queue=Promise.resolve();
const revision=raw=>raw===null?null:createHash('sha256').update(raw).digest('hex');
async function read(){try{return await readFile(file,'utf8');}catch(e){if(e.code==='ENOENT')return null;throw e;}}
export async function profileApi(req,res,next){
 const pathname=req.url.split('?')[0];
 if(pathname==='/api/profile-backup'&&req.method==='GET'){try{const raw=await readFile(directory+'before-import.json','utf8');res.writeHead(200,{'Content-Type':'application/json','Cache-Control':'no-store'});return res.end(raw);}catch{res.writeHead(404);return res.end();}}
 if(pathname!=='/api/profile')return next();
 const send=(status,value)=>{res.writeHead(status,{'Content-Type':'application/json','Cache-Control':'no-store'});res.end(JSON.stringify(value));};
 try{
  if(req.method==='GET'){await queue;const raw=await read();return send(200,{state:raw===null?null:validateState(JSON.parse(raw)),revision:revision(raw)});}
  if(req.method!=='PUT')return send(405,{error:'Metodo non consentito.'});
  if(req.headers.origin&&req.headers.origin!==`http://${req.headers.host}`)return send(403,{error:'Origine non consentita.'});
  if(!req.headers['content-type']?.startsWith('application/json'))return send(415,{error:'JSON richiesto.'});
  let body='';for await(const chunk of req){body+=chunk;if(Buffer.byteLength(body)>10*1024*1024)return send(413,{error:'Salvataggio troppo grande.'});}
  const input=JSON.parse(body),state=validateState(input.state);
  const task=queue.then(async()=>{
   const raw=await read();if(input.revision!==revision(raw))return send(409,{error:'I dati sono cambiati in un altro browser. Ricarica la pagina prima di continuare.'});
   await mkdir(directory,{recursive:true});
   if(input.backup&&raw!==null)await writeFile(directory+'before-import.json',raw);
   const serialized=JSON.stringify(state,null,2);await writeFile(file+'.tmp',serialized);await rename(file+'.tmp',file);
   send(200,{revision:revision(serialized)});
  });queue=task.catch(()=>{});await task;
 }catch(e){send(500,{error:`Salvataggio su disco non completato: ${e.message}`});}
}
