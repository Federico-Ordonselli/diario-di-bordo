import {materials} from './data.js';
import {completionItems} from './completion.js';
import {initialState,transact,validQuantity} from './engine.js';
import {changedTargets,targetValue,writeTarget,snapshotScope} from './save-state.js';
import {screenshotEvidenceById} from './screenshot-progress.js';

const normal=s=>String(s).toLowerCase().replace(/[^a-z0-9]/g,'');
const lookup=(category,title)=>completionItems.find(item=>item.categoryId===category&&normal(item.title)===normal(title));
const bool=(v,label)=>{if(v==null)return null;if(typeof v!=='boolean')throw Error(`${label}: flag non valido.`);return v;};
const quantity=(v,label,max=999999)=>{if(v==null)return null;if(!validQuantity(v)||v>max)throw Error(`${label}: quantità non valida.`);return v;};
const array=(v,label)=>{if(v==null)return [];if(!Array.isArray(v))throw Error(`${label}: elenco non valido.`);return v;};
const date=(v,label)=>{if(typeof v!=='string'||!Number.isFinite(Date.parse(v)))throw Error(`${label}: data non valida.`);return v;};
const spellFamilies={Fire:['Fire','Fira','Firaga'],Blizzard:['Blizzard','Blizzara','Blizzaga'],Thunder:['Thunder','Thundara','Thundaga'],Cure:['Cure','Cura','Curaga'],Gravity:['Gravity','Gravira','Graviga'],Stop:['Stop','Stopra','Stopga'],Aero:['Aero','Aerora','Aeroga']};
export function validateAnalyzedSave(raw) {
 if(!raw||raw.schema!=='kh1fm-save-snapshot'||raw.schema_version!==1)throw Error('Formato snapshot non compatibile: atteso kh1fm-save-snapshot, versione 1.');
 if(!Array.isArray(raw.slots)||!raw.slots.length||raw.slots.length>200||new Set(raw.slots.map(s=>s.slot_number)).size!==raw.slots.length)throw Error('Elenco slot non valido.');
 if(typeof raw.source?.filename!=='string'||!raw.source.filename||typeof raw.source.sha256!=='string'||!/^[a-f0-9]{64}$/i.test(raw.source.sha256))throw Error('Provenienza dello snapshot non valida.');
 date(raw.generated_at,'Data di analisi');
 for(const slot of raw.slots)normalizeSlot(raw,slot.slot_number);
 return raw;
}
export function normalizeSlot(raw,slotNumber) {
 const slot=raw.slots.find(s=>s.slot_number===slotNumber);
 if(!slot||!Number.isInteger(slotNumber)||slotNumber<1)throw Error('Slot non trovato.');
 const observations={};
 const add=(key,value,label,path,confidence='mapped')=>{observations[key]={value,label,path,confidence};};
 const complete=(category,title,value,path,confidence)=>{const item=lookup(category,title);if(!item)throw Error(`Voce non mappata: ${title}.`);add(`completion.${item.id}`,value,`${item.categoryLabel} · ${item.title}`,path,confidence);};
 const inventory=array(slot.inventory,'Inventario');
 if(new Set(inventory.map(item=>item.item_id)).size!==inventory.length)throw Error('ID inventario duplicati.');
 for(const item of inventory){quantity(item.quantity,item.name);if(!Number.isInteger(item.item_id)||item.item_id<0||item.item_id>255)throw Error('ID inventario non valido.');}
 const inventoryNames=new Map(inventory.map(item=>[normal(item.name),item]));
 for(const material of materials) {
  const name=Object.keys(slot.materials||{}).find(n=>normal(n)===normal(material.name));
  const value=quantity(name===undefined?null:slot.materials[name],material.name);
  const rawItem=inventoryNames.get(normal(material.name));
  if(value!==null&&rawItem?.quantity!=null&&value!==rawItem.quantity)throw Error(`Quantità discordanti nello snapshot: ${material.name}.`);
  add(`inventory.${material.id}`,value,material.name,`materials.${name??material.name}${rawItem?` · inventory[item_id=${rawItem.item_id}]`:''}`);
 }
 const keyblades=array(slot.keyblades,'Keyblade');
 if(new Set(keyblades.map(item=>item.name)).size!==keyblades.length)throw Error('Keyblade duplicati.');
 for(const item of completionItems.filter(x=>x.categoryId==='keyblades')) {
  const weapon=keyblades.find(w=>normal(w.name)===normal(item.title));
  complete('keyblades',item.title,bool(weapon?.owned,item.title),`keyblades.${item.title}.owned`,'mapped_current_ownership');
 }
 const magic=array(slot.magic,'Magie');
 if(new Set(magic.map(m=>m.family)).size!==magic.length)throw Error('Famiglie magiche duplicate.');
 for(const [family,names]of Object.entries(spellFamilies)) {
  const spell=magic.find(m=>m.family===family),unlocked=bool(spell?.unlocked,family),tier=quantity(spell?.tier,family,3);
  if(unlocked===true&&tier===0||unlocked===false&&tier>0)throw Error(`Livello e disponibilità discordanti: ${family}.`);
  names.forEach((name,index)=>complete('magic',name,unlocked===false?false:unlocked===null||tier===null?null:index<tier,`magic.${family}.tier`,spell?.confidence||'unknown'));
 }
 for(const name of ['Dumbo','Bambi','Genie','Tinker Bell','Mushu','Simba']) {
  const summon=array(slot.summons,'Invocazioni').find(s=>s.name===name);
  complete('magic',name,bool(summon?.unlocked,name),`summons.${name}.unlocked`,summon?.confidence||'unknown');
 }
 const reports=array(slot.ansem_reports,'Diari di Ansem');
 if(new Set(reports.map(r=>r.number)).size!==reports.length)throw Error('Rapporti di Ansem duplicati.');
 for(let number=1;number<=13;number++) {
  const report=reports.find(r=>r.number===number);
  complete('reports',`Ansem Report ${number}`,bool(report?.unlocked_in_journal,`Ansem ${number}`),`ansem_reports.${number}.unlocked_in_journal`,report?.confidence||'unknown');
 }
 const puppies=array(slot.dalmatians?.groups,'Cuccioli');
 if(new Set(puppies.map(p=>p.start)).size!==puppies.length)throw Error('Gruppi di cuccioli duplicati.');
 for(let start=1;start<=97;start+=3) {
  const puppy=puppies.find(p=>p.start===start&&p.end===start+2);
  complete('dalmatians',`Puppies ${start} - ${start+1} - ${start+2}`,bool(puppy?.rescued,`Cuccioli ${start}`),`dalmatians.groups.${start}-${start+2}`,puppy?.confidence||'unknown');
 }
 const totals={Blue:17,Red:6,Green:9,Yellow:4,White:10};
 for(const [color,total]of Object.entries(totals)) {
  const counter=array(slot.trinities?.by_color,'Contatori Trinità').find(c=>c.color===color);
  if(counter&&counter.total!==total)throw Error(`Totale Trinità ${color} non riconosciuto.`);
  add(`save.trinity.${color}`,quantity(counter?.collected,`Trinità ${color}`,total),`Trinità ${color} / ${total}`,`trinities.by_color.${color}`,slot.trinities?.confidence||'unknown');
 }
 add('save.postcards',quantity(slot.postcards?.mailed,'Cartoline',10),'Cartoline spedite / 10','postcards.mailed',slot.postcards?.confidence||'unknown');
 const chests=array(slot.chests?.checks,'Casse mappate');
 if(chests.length>1500||new Set(chests.map(c=>c.code)).size!==chests.length)throw Error('Mappatura casse non valida.');
 for(const chest of chests) {
  if(!Number.isSafeInteger(chest.code)||chest.code<0||typeof chest.name!=='string'||typeof chest.world!=='string')throw Error('Cassa non valida.');
  add(`save.chest.${chest.code}`,bool(chest.collected,chest.name),chest.name,`chests.checks.${chest.code} · ${chest.offset} bit ${chest.bit}`,chest.confidence||'unknown');
 }
 add('settings.level',quantity(slot.level,'Livello',100),'Livello di Sora','level');
 add('settings.munny',quantity(slot.munny,'Munny'),'Munny salvati','munny');
 const spells=Object.fromEntries(Object.entries(observations).filter(([k])=>k.startsWith('completion.')).map(([k,v])=>[k,v.value]));
 for(const name of ['Stop','Aerora','Aeroga','Dumbo','Bambi','Mushu'])add(`settings.${name}`,spells[`completion.${lookup('magic',name).id}`],`Disponibilità ${name}`,`magic / summons.${name}`,'derived_mapping');
 const characters=array(slot.characters,'Personaggi');
 const sora=characters.find(c=>c.name==='Sora');
 if(sora&&Array.isArray(sora.abilities))add('settings.Ragnarok',sora.abilities.some(a=>a.name==='Ragnarok'),'Ragnarok appreso (non equipaggiamento)','characters.Sora.abilities','mapped');
 if(Array.isArray(slot.shared_abilities))add('settings.Glide',slot.shared_abilities.some(a=>a.name==='Glide'),'Glide disponibile','shared_abilities','mapped');
 const savedAt=date(slot.modified_at,'Data dello slot');
 return {id:`${raw.source.sha256}:${slotNumber}:${savedAt}`,slotNumber,source:structuredClone(raw.source),generatedAt:raw.generated_at,savedAt,level:slot.level??null,location:structuredClone(slot.location||{}),difficulty:slot.difficulty?.name||'Da verificare',observations,chests:chests.map(c=>({code:c.code,name:c.name,world:c.world,offset:c.offset,bit:c.bit,confidence:c.confidence})),characters:structuredClone(characters),extraItems:structuredClone(slot.extra_item_counts||{}),interpretation:structuredClone(raw.interpretation||{}),unknownSections:structuredClone(slot.unknown_sections||{}),chestCoverage:{mappedTotal:slot.chests?.mapped_total??null,gameTotal:slot.chests?.game_total??null,complete:slot.chests?.coverage_complete??false},reportPath:'/KH1FM_Report_Save.md'};
}

function legacyOverrides(state) {
 const values={...(state.manualOverrides?.app||{})},baseline=initialState();
 if(!state.activeSaveId) {
  for(const m of materials)if(state.inventory[m.id]!==baseline.inventory[m.id])values[`inventory.${m.id}`]=state.inventory[m.id];
  for(const [id,value]of Object.entries(state.completion))if(value===true&&!screenshotEvidenceById[id]||value===false||value===null)values[`completion.${id}`]=value;
  for(const [key,value]of Object.entries(state.settings))if(value!==null&&value!==''&&!(['Stop','Trio Bianco','Trio Giallo'].includes(key)&&state.appliedEvidence?.length))values[`settings.${key}`]=value;
  state.transactions.forEach((t,index)=>{
   if(t.origin==='save'||t.origin==='evidence'||t.label.startsWith('Progressi dagli screenshot'))return;
   const after=state.transactions[index+1]?.before||state;
   for(const key of changedTargets(t.before,after))values[key]=targetValue(state,key);
  });
 }
 return values;
}
export function previewSaveImport(state,raw,slotNumber,decisions={}) {
 const snapshot=normalizeSlot(raw,slotNumber),scope=snapshotScope(snapshot);
 const appOverrides=legacyOverrides(state),scopedOverrides=state.manualOverrides?.[scope]||{};
 const overrides={...appOverrides,...scopedOverrides};
 const rows=Object.entries(snapshot.observations).map(([key,observation])=>{
  const before=targetValue(state,key),manual=Object.hasOwn(overrides,key),manualValue=overrides[key];
  // Existing historical confirmations are conflicts when current ownership is
  // absent in a save; never silently erase them on the first import.
  const historical=!state.activeSaveId&&key.startsWith('completion.')&&before===true&&observation.value!==true;
  const conflict=(manual&&!Object.is(manualValue,observation.value))||historical;
  const keep=(manual||historical)&&decisions[key]!=='save';
  const after=keep?(manual?manualValue:before):observation.value;
  return {key,...observation,before,after,manual,historical,conflict,kept:keep,changed:!Object.is(before,after)};
 });
 return {snapshot,rows,appOverrides,scope,changes:rows.filter(r=>r.changed).length,conflicts:rows.filter(r=>r.conflict).length};
}
export function applySaveImport(state,raw,slotNumber,decisions={}) {
 validateAnalyzedSave(raw);
 const preview=previewSaveImport(state,raw,slotNumber,decisions);
 const next=transact(state,`Importazione save · slot ${slotNumber} · ${preview.snapshot.savedAt}`,draft=>{
  draft.manualOverrides.app={...preview.appOverrides};
  const scoped={...(draft.manualOverrides[preview.scope]||{})};
  for(const row of preview.rows) {
   writeTarget(draft,row.key,row.after);
   if(row.kept)scoped[row.key]=row.after;
   else if(decisions[row.key]==='save'){delete scoped[row.key];delete draft.manualOverrides.app[row.key];}
  }
  draft.manualOverrides[preview.scope]=scoped;
  draft.saveSnapshots[preview.snapshot.id]={...preview.snapshot,importedAt:new Date().toISOString()};
  draft.activeSaveId=preview.snapshot.id;
 },'save');
 return next;
}
export function editSaveValue(state,id,value) {
 if(!state.activeSaveId)throw Error('Importa prima uno snapshot.');
 const observation=state.saveSnapshots[state.activeSaveId].observations[`save.${id}`];
 if(!observation)throw Error('Campo del save non riconosciuto.');
 if(id.startsWith('chest.'))bool(value,id);
 else quantity(value,id,id==='postcards'?10:({Blue:17,Red:6,Green:9,Yellow:4,White:10}[id.split('.')[1]]));
 if(state.saveValues[id]===value)return state;
 return transact(state,`Correzione save: ${observation.label}`,draft=>{draft.saveValues[id]=value;});
}
