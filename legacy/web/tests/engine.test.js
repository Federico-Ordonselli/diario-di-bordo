import test from 'node:test';
import assert from 'node:assert/strict';
import {materials,recipes,collections,route15,farming} from '../src/data.js';
import {initialState,distinctCount,unlocked,craft,markCrafted,recipeStatus,plan,simulatePlan,undo,setQuantity,increment,collect,validateState} from '../src/engine.js';
const firstSix=route15.slice(0,6);
const farm15={bright_shard:2,frost_shard:1,power_shard:5,power_gem:2,lucid_gem:3,lightning_stone:1,power_stone:1,mythril_stone:1};
test('Dataset e stato iniziale rispecchiano il PDF',()=>{
 const s=initialState();assert.equal(materials.length,34);assert.equal(recipes.length,33);assert.equal(collections.length,30);
 assert.deepEqual([1,2,3,4,5,6].map(g=>recipes.filter(r=>r.group===g).length),[6,6,6,6,6,3]);
 assert.equal(distinctCount(s),2);assert.equal(s.inventory.lucid_shard,19);assert.equal(s.inventory.power_shard,1);assert.equal(s.inventory.lucid_crystal,null);
 assert.equal(unlocked(s,1),true);assert.equal(unlocked(s,2),false);
 assert.ok(Object.values(s.collections).every(v=>v==='unknown'));
 assert.ok(materials.every(m=>farming.some(f=>f.material===m.id)));
 for(const r of recipes)for(const m of Object.keys(r.costs))assert.ok(materials.find(x=>x.id===m));
});
test('Cottage consuma e sblocca II; annulla ripristina tutto',()=>{
 const s=initialState(),next=craft(s,'cottage');assert.equal(next.inventory.lucid_shard,18);assert.equal(next.inventory.bright_shard,1);assert.equal(distinctCount(next),3);assert.equal(unlocked(next,2),true);
 const back=undo(next);assert.deepEqual(back.inventory,s.inventory);assert.deepEqual(back.everCrafted,s.everCrafted);assert.deepEqual(back.craftCount,s.craftCount);assert.equal(back.transactions.length,0);
});
test('Le sei creazioni iniziali funzionano in sequenza',()=>{
 let s=initialState();for(const id of firstSix)s=craft(s,id);assert.equal(distinctCount(s),8);assert.equal(s.inventory.thunder_shard,0);assert.equal(unlocked(s,3),false);
});
test('Farm minimo, incluse 3 Lucid Gem, arriva esattamente a 15',()=>{
 let s=initialState();s.plan.mode='15';const p=plan(s);for(const [m,n]of Object.entries(farm15))assert.equal(p.rows[m].missing,n,m);
 for(const [id,n]of Object.entries(farm15))s=increment(s,id,n);
 assert.ok(simulatePlan(s).complete);
 for(const id of route15)s=craft(s,id);assert.equal(distinctCount(s),15);assert.ok(unlocked(s,4));assert.ok(Object.values(s.inventory).every(n=>n===null||n>=0));assert.equal(s.inventory.lucid_gem,0);
});
test('Piano globale: costi e dipendenze senza doppio conteggio',()=>{
 const p=plan(initialState());assert.equal(p.counts.dark_matter,3);assert.equal(p.counts.mythril,1);
 for(const [m,n]of Object.entries({lucid_shard:36,gale:6,mythril:16,dark_matter:11}))assert.equal(p.rows[m].external,n,m);
 for(const [m,n]of Object.entries({power_shard:10,power_gem:10,fury_stone:4,bright_crystal:3,mystery_goo:9}))assert.equal(p.rows[m].missing,n,m);
 assert.equal(p.rows.dark_matter.missing,5);assert.equal(p.rows.dark_matter.planned,5);assert.equal(p.rows.dark_matter.uncovered,0);
});
test('Saltare una Dark Matter espande costi; Mythril insufficiente espande a sua volta',()=>{
 const s=initialState(),old=plan(s);s.plan.rewards.dark_matter=4;const next=plan(s);
 assert.equal(next.counts.dark_matter,4);assert.equal(next.rows.lucid_shard.external-old.rows.lucid_shard.external,9);assert.equal(next.rows.gale.external-old.rows.gale.external,1);assert.equal(next.counts.mythril,3);
 s.inventory.mythril=0;const low=plan(s);assert.ok(low.counts.mythril>3);assert.equal(low.rows.mythril.uncovered,0);
});
test('Mythril produce inventario e non incrementa distinti se ripetuto',()=>{
 let s=initialState();for(const id of route15.slice(0,10))s=markCrafted(s,id);
 s=increment(s,'mythril_stone',2);s=increment(s,'mystery_goo',1);const before=s;
 const next=craft(s,'mythril');assert.equal(next.inventory.mythril,before.inventory.mythril+1);assert.equal(next.inventory.mythril_shard,before.inventory.mythril_shard-5);assert.equal(next.inventory.mythril_stone,before.inventory.mythril_stone-1);assert.equal(next.inventory.mystery_goo,before.inventory.mystery_goo-1);
 const repeat=craft(next,'mythril');assert.equal(distinctCount(repeat),distinctCount(next));assert.deepEqual(undo(repeat).inventory,next.inventory);assert.deepEqual(undo(repeat).everCrafted,next.everCrafted);
});
test('Dark Matter consuma e produce correttamente, reversibile',()=>{
 let s=initialState();for(const r of recipes.filter(r=>r.group<5))s=markCrafted(s,r.id);
 const before=s,next=craft(s,'dark_matter');assert.equal(next.inventory.dark_matter,before.inventory.dark_matter+1);assert.equal(next.inventory.lucid_shard,before.inventory.lucid_shard-9);assert.equal(next.inventory.gale,before.inventory.gale-1);assert.equal(next.inventory.mythril,before.inventory.mythril-2);assert.deepEqual(undo(next).inventory,before.inventory);
});
test('Storico non consuma ingredienti; sblocchi solo con distinti dei gruppi precedenti',()=>{
 let s=initialState(),inv=s.inventory;s=markCrafted(s,'ultima_weapon');assert.deepEqual(s.inventory,inv);assert.equal(unlocked(s,2),false);assert.throws(()=>craft(s,'mega_ether'));
 for(const r of recipes.filter(r=>r.group<6))s=markCrafted(s,r.id);assert.equal(unlocked(s,6),true);
 s.everCrafted.cottage=false;assert.equal(unlocked(s,6),false);
});
test('Incognite, valori zero e numeri non validi',()=>{
 let s=initialState();for(const r of recipes.filter(r=>r.group<4))s=markCrafted(s,r.id);
 assert.equal(recipeStatus(s,recipes.find(r=>r.id==='elixir')).unknown,true);assert.equal(recipeStatus(s,recipes.find(r=>r.id==='elixir')).ready,false);
 for(const [m,n]of Object.entries({lucid_crystal:9,power_crystal:3,shiny_crystal:3})){assert.equal(plan(s).rows[m].missing,null);s=setQuantity(s,m,0);assert.equal(plan(s).rows[m].missing,n);}
 assert.throws(()=>setQuantity(s,'power_shard',-1));assert.throws(()=>setQuantity(s,'power_shard',2.5));assert.equal(increment(setQuantity(s,'power_shard',0),'power_shard',-1).inventory.power_shard,0);
 assert.throws(()=>increment(setQuantity(s,'lucid_crystal',null),'lucid_crystal',1));
});
test('Checklist: retroattivo distinto da nuova raccolta, previsione e undo atomici',()=>{
 const s=initialState(),retro=collect(s,'dm_01');assert.equal(retro.inventory.dark_matter,6);assert.equal(retro.plan.rewards.dark_matter,5);
 const now=collect(s,'dm_01',true);assert.equal(now.inventory.dark_matter,7);assert.equal(now.plan.rewards.dark_matter,4);assert.equal(now.collections.dm_01,'collected');assert.throws(()=>collect(now,'dm_01',true));
 const back=undo(now);assert.deepEqual(back.inventory,s.inventory);assert.deepEqual(back.plan,s.plan);assert.deepEqual(back.collections,s.collections);
 assert.equal(plan(now).rows.lucid_shard.external,plan(s).rows.lucid_shard.external);
});
test('Import/export preserva cronologia, null, checklist e piano; rifiuta input invalido',()=>{
 let s=craft(initialState(),'cottage');s=collect(s,'ori_01',true);s.plan.mode='selected';s.plan.selected=['mythril','dark_matter'];
 const imported=validateState(JSON.parse(JSON.stringify(s)));assert.deepEqual(imported,s);assert.deepEqual(undo(imported).inventory,undo(s).inventory);
 const bad=structuredClone(s);bad.inventory.lucid_shard=-1;assert.throws(()=>validateState(bad));bad.inventory.lucid_shard=4;bad.plan.rewards.dark_matter='5';assert.throws(()=>validateState(bad));
});
test('Selezione bloccata: sufficienza aggregata non garantisce ordine eseguibile',()=>{
 const s=initialState();s.plan.mode='selected';s.plan.selected=['ultima_weapon'];for(const m of materials)s.inventory[m.id]=999;
 const p=plan(s);assert.ok(Object.values(p.rows).every(r=>r.sufficient));assert.equal(simulatePlan(s,p).complete,false);
});
test('Output e dipendenze sconosciuti non diventano automaticamente zero',()=>{
 let s=initialState();s=setQuantity(s,'dark_matter',null);const p=plan(s);assert.equal(p.rows.lucid_shard.missing,null);assert.equal(p.rows.gale.sufficient,false);assert.ok(p.uncertainDependencies.includes('dark_matter'));
 s=initialState();for(const r of recipes.filter(r=>r.group<3))s=markCrafted(s,r.id);s=setQuantity(s,'mythril',null);s=increment(s,'mythril_stone',1);assert.equal(recipeStatus(s,recipes.find(r=>r.id==='mythril')).ready,false);assert.throws(()=>craft(s,'mythril'));assert.equal(s.inventory.mythril,null);
});
test('Prime 15 tiene conto di altre ricette già completate e termina a 15',()=>{
 let s=initialState();s.plan.mode='15';s=markCrafted(s,'angel_bangle');const p=plan(s);assert.equal(p.total,12);
 for(const r of recipes.filter(r=>r.group<=3).slice(0,15))s=markCrafted(s,r.id);assert.equal(plan(s).total,0);
});
