import test from 'node:test';
import assert from 'node:assert/strict';
import {initialState,craft,collect,setQuantity,validateState} from '../src/engine.js';
import {loadProfile,saveProfile,importProfile,STORAGE_KEY,BACKUP_KEY} from '../src/storage.js';
const values=new Map();
globalThis.localStorage={getItem:k=>values.get(k)??null,setItem:(k,v)=>values.set(k,String(v))};
const downloads=[];
globalThis.document={createElement:()=>({set href(v){},set download(v){this.name=v;},click(){downloads.push(this.name);}})};
if(!URL.createObjectURL)URL.createObjectURL=()=> 'blob:test';
if(!URL.revokeObjectURL)URL.revokeObjectURL=()=>{};
test('Persistenza conserva tutti i dati dopo una nuova lettura',()=>{
 values.clear();let s=craft(initialState(),'cottage');s=collect(s,'dm_01',true);s=setQuantity(s,'power_crystal',27);saveProfile(s);assert.deepEqual(loadProfile(),s);assert.equal(loadProfile().inventory.lucid_crystal,null);
});
test('Importazione conserva un backup prima della sostituzione',()=>{
 const current=loadProfile(),incoming=initialState();incoming.inventory.lucid_shard=123;saveProfile(current);const imported=importProfile(current,incoming);
 assert.deepEqual(JSON.parse(values.get(BACKUP_KEY)),current);assert.deepEqual(loadProfile(),incoming);assert.deepEqual(imported,incoming);assert.ok(downloads.at(-1).startsWith('kh1fm-prima-importazione'));
});
test('Salvataggio non valido è rifiutato senza modificarne il contenuto',()=>{
 const corrupt='{"schemaVersion":8}';values.set(STORAGE_KEY,corrupt);assert.throws(loadProfile);assert.equal(values.get(STORAGE_KEY),corrupt);saveProfile(initialState());
});
test('Errore di persistenza durante importazione lascia il profilo precedente',()=>{
 const current=initialState(),incoming=initialState();incoming.inventory.lucid_shard=80;saveProfile(current);const setter=localStorage.setItem;localStorage.setItem=(k,v)=>{if(k===STORAGE_KEY)throw Error('Quota esaurita');setter(k,v);};
 assert.throws(()=>importProfile(current,incoming),/Quota/);localStorage.setItem=setter;assert.deepEqual(loadProfile(),current);assert.deepEqual(JSON.parse(values.get(BACKUP_KEY)),current);
});
