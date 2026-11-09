import test from 'node:test';
import assert from 'node:assert/strict';
import {initialState,setCompletion,undo,validateState} from '../src/engine.js';
import {completionItems,completionSummary} from '../src/completion.js';
import {applyScreenshotProgress,screenshotEvidence,screenshotImportId} from '../src/screenshot-progress.js';

const item=(categoryId,title)=>completionItems.find(x=>x.categoryId===categoryId&&x.title===title);
test('Screenshot: 21 achievement e solo sblocchi identificabili',()=>{
 const before=initialState(),after=applyScreenshotProgress(before);
 assert.equal(completionSummary(after,'achievements').done,21);
 assert.equal(completionSummary(after,'dalmatians').done,33);
 assert.equal(completionSummary(after,'treasures').done,33);
 assert.equal(completionSummary(after,'coliseum').done,3);
 assert.equal(completionSummary(after,'missions').done,0);
 assert.equal(completionSummary(after,'minigames').done,0);
 assert.equal(completionSummary(after).done,220);
 assert.ok(screenshotEvidence.every(x=>x.reason&&x.title));
 assert.deepEqual(after.inventory,before.inventory);assert.deepEqual(after.everCrafted,before.everCrafted);
 assert.deepEqual(after.craftCount,before.craftCount);assert.deepEqual(after.plan,before.plan);
 assert.equal(after.settings.level,null);assert.equal(after.settings.munny,null);
 for(const [category,title] of [['coliseum','Phil Cup (Solo)'],['coliseum','Hades Cup (Standard)'],['keyblades','Olympia'],['magic','Curaga'],['magic','Aeroga'],['magic','Mushu'],['reports','Ansem Report 2'],['characters','Sephiroth'],['characters','Winnie the Pooh'],['blueprints','Cid']])assert.ok(!after.completion[item(category,title).id],`${title} non deve essere dedotto`);
 assert.equal(after.settings['Trio Bianco'],true);assert.equal(after.settings['Trio Giallo'],true);
});

test('Importazione cumulativa, unica, persistente e annullabile senza riapplicazione',()=>{
 const completed=item('keyblades','Ultima Weapon');
 const before=setCompletion(initialState(),completed.id,true),after=applyScreenshotProgress(before);
 assert.ok(after.completion[completed.id]);assert.equal(after.transactions.length,before.transactions.length+1);
 assert.equal(applyScreenshotProgress(after),after);
 const reloaded=validateState(JSON.parse(JSON.stringify(after)));
 assert.deepEqual(reloaded,after);assert.equal(applyScreenshotProgress(reloaded),reloaded);
 const restored=undo(after);
 assert.deepEqual(restored.completion,before.completion);assert.deepEqual(restored.settings,before.settings);
 assert.ok(restored.appliedEvidence.includes(screenshotImportId));assert.equal(applyScreenshotProgress(restored),restored);
 const corrected=setCompletion(after,item('achievements','Top Dog').id,false);
 assert.equal(applyScreenshotProgress(corrected),corrected);
});

test('Backup precedenti senza marcatori accettati, marcatori corrotti rifiutati',()=>{
 const previous=initialState();delete previous.appliedEvidence;
 assert.deepEqual(validateState(previous).appliedEvidence,[]);
 for(const evidence of [false,{},[null],['same','same']]){const raw=initialState();raw.appliedEvidence=evidence;assert.throws(()=>validateState(raw));}
});
