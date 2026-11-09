import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initialState,setQuantity,setCompletion,undo,validateState} from '../src/engine.js';
import {completionItems,completionStatus} from '../src/completion.js';
import {applySaveImport,previewSaveImport,validateAnalyzedSave,editSaveValue} from '../src/save-adapter.js';
const fixture=JSON.parse(readFileSync(new URL('../public/KH1FM_Save_Analizzato.json',import.meta.url),'utf8'));
const item=(category,title)=>completionItems.find(x=>x.categoryId===category&&x.title===title);

test('Adattatore: slot 1, 34 materiali inclusi zeri, magie/evocazioni, rapporti e cuccioli',()=>{
 validateAnalyzedSave(fixture);
 const before=initialState(),next=applySaveImport(before,fixture,1);
 assert.equal(next.inventory.blaze_shard,10);assert.equal(next.inventory.dark_matter,8);assert.equal(next.inventory.mythril,17);
 for(const id of ['blazing_stone','lucid_crystal','power_crystal','shiny_crystal','lightning_stone'])assert.equal(next.inventory[id],0);
 assert.equal(next.settings.level,53);assert.equal(next.settings.munny,5448);assert.equal(next.settings.mp,null);
 assert.equal(next.completion[item('magic','Curaga').id],true);assert.equal(next.completion[item('magic','Stopra').id],true);
 assert.equal(next.completion[item('magic','Stopga').id],false);assert.equal(next.completion[item('magic','Mushu').id],false);
 assert.equal(next.completion[item('reports','Ansem Report 2').id],true);assert.equal(next.completion[item('reports','Ansem Report 8').id],false);
 assert.equal(completionItems.filter(x=>x.categoryId==='dalmatians'&&next.completion[x.id]).length,33);
 assert.equal(next.saveValues['trinity.Blue'],16);assert.equal(next.saveValues['trinity.White'],8);assert.equal(next.saveValues.postcards,6);
 const snapshot=next.saveSnapshots[next.activeSaveId];assert.equal(snapshot.slotNumber,1);assert.equal(snapshot.location.save_label,'Jungle: Tunnel');assert.equal(snapshot.chests.length,228);
 assert.equal(snapshot.chests.filter(c=>next.saveValues[`chest.${c.code}`]===true).length,209);
 assert.equal(snapshot.chestCoverage.gameTotal,null);assert.equal(snapshot.chestCoverage.complete,false);
 assert.deepEqual(next.everCrafted,before.everCrafted);assert.deepEqual(next.craftCount,before.craftCount);assert.deepEqual(next.collections,before.collections);assert.deepEqual(next.plan,before.plan);
});

test('Solo lo slot selezionato: non sommare inventari, override legati allo slot',()=>{
 const one=applySaveImport(initialState(),fixture,1);
 const edited=setQuantity(one,'mythril',88);
 const two=applySaveImport(edited,fixture,2);
 assert.equal(two.inventory.mythril,fixture.slots[1].materials.Mythril);
 assert.equal(two.settings.level,44);assert.equal(two.settings.munny,5739);
 const returned=applySaveImport(two,fixture,1);assert.equal(returned.inventory.mythril,88);
 assert.equal(Object.keys(returned.saveSnapshots).length,2);
 const selected=returned.saveSnapshots[returned.activeSaveId];assert.equal(selected.slotNumber,1);
});

test('Override manuali, conflitti, scelta esplicita e altre checklist conservate',()=>{
 let before=setQuantity(initialState(),'lucid_crystal',7);
 before=setCompletion(before,item('achievements','Top Dog').id,true);
 before=setCompletion(before,item('keyblades','Ultima Weapon').id,true);
 before.everCrafted.ultima_weapon=true;
 const preview=previewSaveImport(before,fixture,1),key='inventory.lucid_crystal';
 assert.ok(preview.rows.find(r=>r.key===key).conflict);assert.equal(preview.rows.find(r=>r.key===key).after,7);
 const kept=applySaveImport(before,fixture,1);assert.equal(kept.inventory.lucid_crystal,7);assert.equal(kept.completion[item('keyblades','Ultima Weapon').id],true);
 assert.equal(kept.completion[item('achievements','Top Dog').id],true);assert.equal(kept.everCrafted.ultima_weapon,true);
 const chosen=applySaveImport(before,fixture,1,{[key]:'save'});assert.equal(chosen.inventory.lucid_crystal,0);
 assert.equal(applySaveImport(chosen,fixture,1).inventory.lucid_crystal,0);
});

test('null rimane sconosciuto e non azzera sezioni non decodificate',()=>{
 const raw=structuredClone(fixture);raw.slots[0].materials['Lucid Crystal']=null;
 raw.slots[0].magic.find(m=>m.family==='Blizzard').tier=null;
 raw.slots[0].ansem_reports.find(r=>r.number===8).unlocked_in_journal=null;
 const before=initialState();before.completion[item('coliseum','Hades Cup (Standard)').id]=true;
 const next=applySaveImport(before,raw,1);
 assert.equal(next.inventory.lucid_crystal,null);
 const unknown=item('magic','Blizzara');assert.equal(next.completion[unknown.id],null);assert.equal(completionStatus(next,unknown),'unknown');
 assert.equal(next.completion[item('reports','Ansem Report 8').id],null);
 assert.equal(next.completion[item('coliseum','Hades Cup (Standard)').id],true);
 assert.equal(setCompletion(next,unknown.id,false).completion[unknown.id],false);
 assert.deepEqual(validateState(JSON.parse(JSON.stringify(next))),next);
});

test('Backup/undo integrali e snapshot archiviati una sola volta',()=>{
 const initial=initialState(),one=applySaveImport(initial,fixture,1);
 const id=one.saveSnapshots[one.activeSaveId].chests[0].code;
 const edited=editSaveValue(one,`chest.${id}`,null);
 assert.equal(edited.saveValues[`chest.${id}`],null);
 const back=undo(edited);assert.equal(back.saveValues[`chest.${id}`],true);
 const reverted=undo(back);assert.deepEqual(reverted.inventory,initial.inventory);assert.deepEqual(reverted.completion,initial.completion);assert.deepEqual(reverted.settings,initial.settings);assert.equal(reverted.activeSaveId,null);
 assert.equal(Object.keys(reverted.saveSnapshots).length,1);
 assert.ok(one.transactions.every(t=>!Object.hasOwn(t.before,'saveSnapshots')));
 assert.deepEqual(validateState(JSON.parse(JSON.stringify(edited))),edited);
 assert.deepEqual(validateState(JSON.parse(JSON.stringify(reverted))),reverted);
});

test('Snapshot e override corrotti rifiutati senza importazione parziale',()=>{
 for(const change of [r=>r.schema_version=5,r=>r.slots[0].materials.Mythril=-1,r=>r.slots[0].summons[0].unlocked='yes',r=>r.slots[0].chests.checks.push(r.slots[0].chests.checks[0]),r=>r.slots[0].trinities.by_color[0].collected=18]) {
  const raw=structuredClone(fixture);change(raw);assert.throws(()=>applySaveImport(initialState(),raw,1));
 }
 const bad=initialState();bad.manualOverrides={app:{'inventory.mythril':'bad'}};assert.throws(()=>validateState(bad));
 assert.throws(()=>applySaveImport(initialState(),fixture,99));
});
