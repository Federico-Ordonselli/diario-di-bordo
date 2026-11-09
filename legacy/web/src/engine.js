import { materials, recipes, collections, route15 } from './data.js';
import {workbook,initialCompletion,validateCompletion,completionById,isCompleted} from './completion.js';
import {emptySaveState,recordManualChanges,validateSaveState} from './save-state.js';
export const datasetVersion = 'kh1fm-2026-10-09';
export const recipeById = Object.fromEntries(recipes.map(r=>[r.id,r]));
export const materialById = Object.fromEntries(materials.map(m=>[m.id,m]));
export const clone = value => structuredClone(value);
export const validQuantity = n => Number.isSafeInteger(n) && n >= 0 && n <= 999999;
export function initialState() {
 return {...emptySaveState(),schemaVersion:2,datasetVersion,completionDatasetVersion:workbook.version,completion:initialCompletion(),appliedEvidence:[],storyPoint:'end_of_the_world',inventory:Object.fromEntries(materials.map(m=>[m.id,m.initial])),everCrafted:Object.fromEntries(recipes.map(r=>[r.id,['energy_bangle','power_chain'].includes(r.id)])),craftCount:Object.fromEntries(recipes.map(r=>[r.id,['energy_bangle','power_chain'].includes(r.id)?null:0])),collections:Object.fromEntries(collections.map(c=>[c.id,'unknown'])),plan:{mode:'all',selected:[],rewards:{dark_matter:5,orichalcum:10}},settings:{edition:'',level:null,mp:null,lucky:null,munny:null,Stop:null,Aerora:null,Aeroga:null,Ragnarok:null,Glide:null,Dumbo:null,Bambi:null,Mushu:null,'Trio Bianco':null,'Trio Giallo':null},session:{},transactions:[],updatedAt:new Date().toISOString()};
}
export const distinctCount = s => recipes.filter(r=>s.everCrafted[r.id]).length;
export function unlocked(s,g) {
 if(g===1)return true;
 const previous=recipes.filter(r=>r.group<g);
 const count=previous.filter(r=>s.everCrafted[r.id]).length;
 return g===6 ? count===30 : count >= ({2:3,3:9,4:15,5:21}[g]);
}
export function recipeStatus(s,r) {
 const unknown=Object.keys(r.costs).some(m=>s.inventory[m]===null)||(r.output&&s.inventory[r.output]===null);
 const deficits=Object.entries(r.costs).map(([m,n])=>({id:m,need:n,have:s.inventory[m],missing:s.inventory[m]===null?null:Math.max(0,n-s.inventory[m])}));
 return {unlocked:unlocked(s,r.group),unknown,deficits,ready:unlocked(s,r.group)&&!unknown&&deficits.every(d=>d.missing===0)};
}
export function route15Remaining(s) {
 const completed=recipes.filter(r=>r.group<=3&&s.everCrafted[r.id]).length;
 return route15.filter(id=>!s.everCrafted[id]).slice(0,Math.max(0,15-completed));
}
export function plan(s) {
 const ids=s.plan.mode==='all'?recipes.map(r=>r.id):s.plan.mode==='15'?route15Remaining(s):s.plan.selected;
 const counts=Object.fromEntries(recipes.map(r=>[r.id,ids.includes(r.id)&&!s.everCrafted[r.id]?1:0]));
 const rewards={dark_matter:s.plan.mode==='15'?0:s.plan.rewards.dark_matter,orichalcum:s.plan.mode==='15'?0:s.plan.rewards.orichalcum};
 const uncertain=new Set();
 const totals=()=>{
  const gross=Object.fromEntries(materials.map(m=>[m.id,0])),produced={...gross};
  for(const r of recipes){for(const [m,n]of Object.entries(r.costs))gross[m]+=n*counts[r.id];if(r.output)produced[r.output]+=counts[r.id];}
  return {gross,produced};
 };
 // Expand the acyclic producer graph: Dark Matter -> Mythril -> basic materials.
 for(const m of ['dark_matter','mythril']) {
  const {gross,produced}=totals();
  if(s.inventory[m]===null && gross[m]>0){uncertain.add(m);for(const ingredient of Object.keys(recipeById[m].costs))uncertain.add(ingredient);if(m==='dark_matter'&&s.inventory.mythril===null)for(const ingredient of Object.keys(recipeById.mythril.costs))uncertain.add(ingredient);}
  const short=Math.max(0,gross[m]-produced[m]-(s.inventory[m]??0)-(rewards[m]||0));
  counts[m]+=short;
 }
 const {gross,produced}=totals();
 const rows=Object.fromEntries(materials.map(m=>{
  const external=Math.max(0,gross[m.id]-produced[m.id]);
  const missing=s.inventory[m.id]===null||uncertain.has(m.id)?null:Math.max(0,external-s.inventory[m.id]);
  const planned=missing===null?null:Math.min(missing,rewards[m.id]||0);
  return [m.id,{gross:gross[m.id],produced:produced[m.id],external,uncertain:uncertain.has(m.id),missing,planned,uncovered:missing===null?null:missing-planned,sufficient:missing===0,unknown:missing===null}];
 }));
 return {counts,rows,rewards,uncertainDependencies:[...uncertain],total:Object.values(counts).reduce((a,b)=>a+b,0)};
}
export function simulatePlan(s,p=plan(s)) {
 const virtual=clone(s),left={...p.counts},steps=[];
 for(const [m,n]of Object.entries(p.rewards))if(virtual.inventory[m]!==null)virtual.inventory[m]+=n;
 for(let i=0;i<500;i++){
  const next=recipes.find(r=>left[r.id]>0&&recipeStatus(virtual,r).ready);
  if(!next)break;
  for(const [m,n]of Object.entries(next.costs))virtual.inventory[m]-=n;
  if(next.output)virtual.inventory[next.output]++;
  virtual.everCrafted[next.id]=true;left[next.id]--;steps.push(next.id);
 }
 return {steps,left,complete:Object.values(left).every(n=>n===0),assumesRewards:Object.values(p.rewards).some(n=>n>0)};
}
export function transact(s,label,action,origin='manual') {
 const next=clone(s),before=clone(s);delete before.transactions;
 delete before.saveSnapshots;
 action(next);
 if(origin==='manual')recordManualChanges(s,next);
 next.updatedAt=new Date().toISOString();
 next.transactions=[...s.transactions,{label,at:next.updatedAt,origin,before}].slice(-100);
 return next;
}
export function setQuantity(s,id,value) {
 if(!materialById[id]||!(value===null||validQuantity(value)))throw Error('Inserisci un intero tra 0 e 999999, oppure lascia il campo vuoto per un valore sconosciuto.');
 if(s.inventory[id]===value)return s;
 return transact(s,`${materialById[id].name}: ${s.inventory[id]??'?'} → ${value??'?'}`,n=>{n.inventory[id]=value;});
}
export function increment(s,id,delta) {
 if(s.inventory[id]===null)throw Error('Quantità sconosciuta: inserisci prima la scorta reale nel campo.');
 return setQuantity(s,id,Math.min(999999,Math.max(0,s.inventory[id]+delta)));
}
export function setCompletion(s,id,done) {
 const item=Object.hasOwn(completionById,id)?completionById[id]:undefined;
 if(!item||!(typeof done==='boolean'||done===null&&!item.recipeId))throw Error('Voce della checklist non valida.');
 if(item.recipeId?isCompleted(s,item)===done:Object.hasOwn(s.completion,id)&&s.completion[id]===done)return s;
 return transact(s,`${done?'Completato':'Da completare'}: ${item.title}`,n=>{
  if(item.recipeId){n.everCrafted[item.recipeId]=done;n.craftCount[item.recipeId]=null;}
  else n.completion[id]=done;
 });
}
export function markCrafted(s,id) {
 if(s.everCrafted[id])return s;
 return transact(s,`Già sintetizzato: ${recipeById[id].name}`,n=>{n.everCrafted[id]=true;n.craftCount[id]=null;});
}
export function craft(s,id) {
 const r=recipeById[id];if(!r)throw Error('Ricetta non valida.');
 if(!recipeStatus(s,r).ready)throw Error('Servono gruppo sbloccato e quantità sufficienti e confermate.');
 return transact(s,`Sintesi: ${r.name}`,n=>{for(const [m,q]of Object.entries(r.costs))n.inventory[m]-=q;if(r.output){if(n.inventory[r.output]===999999)throw Error('Scorta al limite.');n.inventory[r.output]++;}n.everCrafted[id]=true;n.craftCount[id]=n.craftCount[id]===null?null:n.craftCount[id]+1;});
}
export function collect(s,id,now=false,status='collected') {
 const c=collections.find(c=>c.id===id);if(!c)throw Error('Fonte non valida.');
 if(now&&s.collections[id]==='collected')throw Error('Questa fonte risulta già raccolta.');
 if(now&&s.inventory[c.material]===null)throw Error('Conferma prima la scorta del materiale.');
 if(!now&&s.collections[id]===status)return s;
 return transact(s,`${now?'Raccolto adesso':'Stato fonte'}: ${c.world} / ${c.area}`,n=>{
  n.collections[id]=status;
  if(now){if(n.inventory[c.material]>=999999)throw Error('Scorta al limite.');n.inventory[c.material]++;n.plan.rewards[c.material]=Math.max(0,n.plan.rewards[c.material]-1);}
 });
}
export function undo(s) {
 const t=s.transactions.at(-1);if(!t)return s;
 return {...clone(t.before),saveSnapshots:clone(s.saveSnapshots||{}),appliedEvidence:[...(s.appliedEvidence||[])],transactions:s.transactions.slice(0,-1),updatedAt:new Date().toISOString()};
}
export function validateState(raw,withHistory=true) {
 if(!raw||![1,2].includes(raw.schemaVersion)||raw.datasetVersion!==datasetVersion)throw Error('Versione del backup non compatibile.');
 if(raw.schemaVersion===2&&raw.completionDatasetVersion!==workbook.version)throw Error('Versione della checklist non compatibile.');
 const s=initialState();
 s.completion=validateCompletion(raw.completion,raw.schemaVersion===1);
 Object.assign(s,validateSaveState(raw));
 const evidence=raw.appliedEvidence??[];
 if(!Array.isArray(evidence)||evidence.length>100||evidence.some(id=>typeof id!=='string'||id.length>150)||new Set(evidence).size!==evidence.length)throw Error('Importazioni dei progressi non valide.');
 s.appliedEvidence=[...evidence];
 for(const m of materials){const n=raw.inventory?.[m.id];if(!(n===null||validQuantity(n)))throw Error(`Quantità non valida: ${m.name}`);s.inventory[m.id]=n;}
 for(const r of recipes){if(typeof raw.everCrafted?.[r.id]!=='boolean')throw Error(`Completamento non valido: ${r.name}`);s.everCrafted[r.id]=raw.everCrafted[r.id];const n=raw.craftCount?.[r.id];if(!(n===null||validQuantity(n)))throw Error(`Conteggio non valido: ${r.name}`);s.craftCount[r.id]=n;}
 for(const c of collections){if(!['unknown','collected','not_collected'].includes(raw.collections?.[c.id]))throw Error('Stato fonte non valido.');s.collections[c.id]=raw.collections[c.id];}
 if(!['all','15','selected'].includes(raw.plan?.mode)||!Array.isArray(raw.plan.selected)||raw.plan.selected.length>33||raw.plan.selected.some(id=>!recipeById[id])||new Set(raw.plan.selected).size!==raw.plan.selected.length)throw Error('Piano non valido.');
 for(const id of ['dark_matter','orichalcum'])if(!validQuantity(raw.plan.rewards?.[id]))throw Error('Ricompense non valide.');
 s.plan=clone(raw.plan);
 for(const key of Object.keys(s.settings)){const n=raw.settings?.[key]??s.settings[key];if(key==='edition'){if(typeof n!=='string'||n.length>100)throw Error('Edizione non valida.');}else if(['level','mp','lucky','munny'].includes(key)){if(n!==null&&(!validQuantity(n)||(key==='lucky'&&n>3)))throw Error('Configurazione numerica non valida.');}else if(n!==null&&typeof n!=='boolean')throw Error('Abilità non valida.');s.settings[key]=n;}
 if(raw.session)for(const m of materials){const n=raw.session[m.id];if(n!==undefined){if(!validQuantity(n))throw Error('Sessione non valida.');s.session[m.id]=n;}}
 if(withHistory){if(!Array.isArray(raw.transactions)||raw.transactions.length>100)throw Error('Cronologia non valida.');s.transactions=raw.transactions.map(t=>{if(typeof t.label!=='string'||t.label.length>500||typeof t.at!=='string')throw Error('Operazione non valida.');const before=validateState({...t.before,saveSnapshots:s.saveSnapshots,transactions:[]},false);delete before.transactions;delete before.saveSnapshots;const origin=t.origin??(t.label.startsWith('Progressi dagli screenshot')?'evidence':'manual');if(!['manual','save','evidence'].includes(origin))throw Error('Origine operazione non valida.');return {label:t.label,at:t.at,origin,before};});}
 s.updatedAt=typeof raw.updatedAt==='string'?raw.updatedAt:s.updatedAt;
 return s;
}
