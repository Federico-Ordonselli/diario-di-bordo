import test from 'node:test';
import assert from 'node:assert/strict';
import {categories,completionItems,completionSummary,completionById,isCompleted,workbook} from '../src/completion.js';
import {initialState,setCompletion,markCrafted,craft,undo,validateState,setQuantity} from '../src/engine.js';

test('Excel: tutte le 794 voci, intestazioni, sezioni, link e righe sorgente',()=>{
 const expected={achievements:56,coliseum:14,reports:13,characters:160,dalmatians:33,minigames:18,trinities:46,treasures:268,synthesis:33,blueprints:48,missions:30,keyblades:18,staves:15,shields:15,magic:27};
 assert.equal(categories.length,15);assert.equal(completionItems.length,794);
 assert.equal(new Set(completionItems.map(x=>x.id)).size,794);
 for(const c of categories){assert.equal(c.items.length,expected[c.id]);assert.ok(c.columns.length);assert.ok(c.items.every(x=>x.row>2&&x.title&&x.fields));}
 assert.equal(completionItems.filter(x=>x.recipeId).length,33);
 assert.ok(categories.find(x=>x.id==='dalmatians').notes.some(x=>x.links.some(l=>l.url==='https://www.khguides.com/kh/collectibles/puppies/')));
 assert.ok(completionItems.some(x=>x.categoryId==='achievements'&&x.links.some(l=>l.category==='treasures')));
 assert.ok(completionItems.filter(x=>x.categoryId==='treasures').every(x=>x.world));
 assert.equal(workbook.guides.find(x=>x.id==='materials').sections.length,34);
});

test('Progresso reale, spunte indipendenti, idempotenza e annullamento',()=>{
 const initial=initialState(),treasure=completionItems.find(x=>x.categoryId==='treasures');
 assert.deepEqual(completionSummary(initial),{done:2,total:794,remaining:792,percent:0.3});
 const next=setCompletion(initial,treasure.id,true);
 assert.equal(completionSummary(next).done,3);assert.equal(completionSummary(next,'treasures').done,1);
 assert.deepEqual(next.inventory,initial.inventory);assert.deepEqual(next.collections,initial.collections);
 assert.equal(completionSummary(next,'achievements').done,0);
 assert.equal(setCompletion(next,treasure.id,true),next);
 assert.deepEqual(undo(next).completion,initial.completion);
 assert.equal(completionSummary(setCompletion(next,treasure.id,false)).done,2);
 assert.throws(()=>setCompletion(initial,'missing',true));assert.throws(()=>setCompletion(initial,treasure.id,'true'));
});

test('La sintesi ha un solo storico condiviso, senza doppio conteggio o consumo retroattivo',()=>{
 const initial=initialState(),item=completionItems.find(x=>x.recipeId==='cottage');
 const checked=setCompletion(initial,item.id,true);
 assert.equal(completionSummary(checked,'synthesis').done,3);assert.equal(checked.everCrafted.cottage,true);
 assert.deepEqual(checked.inventory,initial.inventory);assert.equal(checked.craftCount.cottage,null);
 assert.ok(!(item.id in checked.completion));
 assert.ok(isCompleted(craft(initial,'cottage'),item));assert.ok(isCompleted(markCrafted(initial,'cottage'),item));
 const corrected=setCompletion(checked,item.id,false);
 assert.equal(corrected.everCrafted.cottage,false);assert.equal(completionSummary(corrected).done,2);
 assert.equal(undo(corrected).everCrafted.cottage,true);
});

function legacySnapshot(state){const raw=structuredClone(state);raw.schemaVersion=1;delete raw.completion;delete raw.completionDatasetVersion;return raw;}
test('Migrazione di profili e cronologia v1 conserva inventario, ricette, piano e undo',()=>{
 const current=setQuantity(initialState(),'lucid_shard',73),legacy=legacySnapshot(current);
 legacy.transactions=legacy.transactions.map(t=>({...t,before:legacySnapshot(t.before)}));
 const migrated=validateState(legacy);
 assert.equal(migrated.schemaVersion,2);assert.equal(migrated.inventory.lucid_shard,73);
 assert.deepEqual(migrated.everCrafted,current.everCrafted);assert.deepEqual(migrated.plan,current.plan);
 assert.equal(completionSummary(migrated).done,2);
 const first=completionItems.find(x=>!x.recipeId);
 const edited=setCompletion(migrated,first.id,true),back=undo(edited);
 assert.equal(completionSummary(back).done,2);assert.equal(undo(back).inventory.lucid_shard,19);
 assert.equal(undo(back).schemaVersion,2);
});

test('Backup 100% round-trip con cronologia, rifiuto di dati corrotti e versioni sconosciute',()=>{
 const id=completionItems.find(x=>x.categoryId==='magic').id;
 const state=setCompletion(setQuantity(initialState(),'power_shard',9),id,true);
 assert.deepEqual(validateState(JSON.parse(JSON.stringify(state))),state);
 for(const value of ['true',1]){const bad=structuredClone(state);bad.completion[id]=value;assert.throws(()=>validateState(bad));}
 const unknown=structuredClone(state);unknown.completion.other=true;assert.throws(()=>validateState(unknown));
 const absent=structuredClone(state);delete absent.completion;assert.throws(()=>validateState(absent));
 const future=structuredClone(state);future.completionDatasetVersion='future';assert.throws(()=>validateState(future));
 const history=structuredClone(state);history.transactions[0].before.completion[id]='broken';assert.throws(()=>validateState(history));
 assert.equal(completionById[id].categoryId,'magic');
});
