// Save observations and user edits are kept separate. Archives are immutable and
// referenced by undo snapshots, rather than copied into every history entry.
import {materials} from './data.js';
import {completionById} from './completion.js';
export const emptySaveState=()=>({saveSnapshots:{},activeSaveId:null,saveValues:{},manualOverrides:{}});
const settings=new Set(['edition','level','mp','lucky','munny','Stop','Aerora','Aeroga','Ragnarok','Glide','Dumbo','Bambi','Mushu','Trio Bianco','Trio Giallo']);
function validTarget(key,value) {
 const [kind,...parts]=key.split('.'),id=parts.join('.');
 const count=(max=999999)=>value===null||Number.isSafeInteger(value)&&value>=0&&value<=max;
 const flag=()=>value===null||typeof value==='boolean';
 if(kind==='inventory')return materials.some(m=>m.id===id)&&count();
 if(kind==='completion')return Object.hasOwn(completionById,id)&&!completionById[id].recipeId&&flag();
 if(kind==='settings')return settings.has(id)&&(id==='edition'?typeof value==='string'&&value.length<=100:['level','mp','lucky','munny'].includes(id)?count(id==='lucky'?3:999999):flag());
 if(kind==='save')return /^chest\.\d+$/.test(id)?flag():id==='postcards'?count(10):/^trinity\.(Blue|Red|Green|Yellow|White)$/.test(id)&&count({Blue:17,Red:6,Green:9,Yellow:4,White:10}[parts[1]]);
 return false;
}
export function targetValue(state,key) {
 const [kind,...rest]=key.split('.'),id=rest.join('.');
 if(kind==='inventory')return state.inventory[id];
 if(kind==='settings')return state.settings[id];
 if(kind==='completion')return Object.hasOwn(state.completion,id)?state.completion[id]:false;
 if(kind==='save')return state.saveValues?.[id]??null;
 throw Error('Campo di importazione non riconosciuto.');
}
export function writeTarget(state,key,value) {
 const [kind,...rest]=key.split('.'),id=rest.join('.');
 if(kind==='inventory')state.inventory[id]=value;
 else if(kind==='settings')state.settings[id]=value;
 else if(kind==='completion')state.completion[id]=value;
 else if(kind==='save')state.saveValues[id]=value;
 else throw Error('Campo di importazione non riconosciuto.');
}
export const snapshotScope=snapshot=>`${snapshot.source.filename}#slot:${snapshot.slotNumber}`;
export const currentScope=state=>state.activeSaveId?snapshotScope(state.saveSnapshots[state.activeSaveId]):'app';
export function changedTargets(before,after) {
 const keys=new Set();
 for(const [prefix,field] of [['inventory','inventory'],['settings','settings'],['completion','completion'],['save','saveValues']])
  for(const id of new Set([...Object.keys(before[field]||{}),...Object.keys(after[field]||{})]))keys.add(`${prefix}.${id}`);
 return [...keys].filter(key=>!Object.is(targetValue(before,key),targetValue(after,key)));
}
export function recordManualChanges(before,after) {
 const scope=currentScope(before);
 const overrides={...(after.manualOverrides||{}),[scope]:{...(after.manualOverrides?.[scope]||{})}};
 for(const key of changedTargets(before,after))overrides[scope][key]=targetValue(after,key);
 after.manualOverrides=overrides;
}
export function validateSaveState(raw) {
 const result=emptySaveState();
 for(const field of ['saveSnapshots','saveValues','manualOverrides']) {
  const value=raw[field]??{};
  if(typeof value!=='object'||value===null||Array.isArray(value))throw Error('Metadati del save non validi.');
  result[field]=structuredClone(value);
 }
 if(Object.keys(result.saveSnapshots).length>100)throw Error('Troppi snapshot nel backup.');
 for(const [id,snapshot] of Object.entries(result.saveSnapshots)) {
  if(!snapshot||snapshot.id!==id||!Number.isInteger(snapshot.slotNumber)||snapshot.slotNumber<1||snapshot.slotNumber>200||typeof snapshot.savedAt!=='string'||!snapshot.source||typeof snapshot.source.filename!=='string'||!snapshot.observations||!Array.isArray(snapshot.chests)||snapshot.chests.length>1500)throw Error('Snapshot archiviato non valido.');
  for(const [key,observation] of Object.entries(snapshot.observations))if(!observation||!validTarget(key,observation.value)||typeof observation.label!=='string'||typeof observation.path!=='string')throw Error('Osservazione del save non valida.');
 }
 result.activeSaveId=raw.activeSaveId??null;
 if(result.activeSaveId!==null&&!Object.hasOwn(result.saveSnapshots,result.activeSaveId))throw Error('Snapshot attivo non trovato nel backup.');
 for(const [key,value] of Object.entries(result.saveValues))if(!validTarget(`save.${key}`,value))throw Error('Contatore o cassa del save non valido.');
 for(const overrides of Object.values(result.manualOverrides)) {
  if(!overrides||typeof overrides!=='object'||Array.isArray(overrides))throw Error('Override manuali non validi.');
  for(const [key,value] of Object.entries(overrides))if(!validTarget(key,value))throw Error('Override manuale non valido.');
 }
 return result;
}
export function saveProvenance(state,key) {
 const snapshot=state.saveSnapshots?.[state.activeSaveId];
 const observation=snapshot?.observations[key];
 if(!observation)return null;
 const manual=Object.hasOwn(state.manualOverrides?.[snapshotScope(snapshot)]||{},key)||Object.hasOwn(state.manualOverrides?.app||{},key);
 return {snapshot,observation,manual};
}
