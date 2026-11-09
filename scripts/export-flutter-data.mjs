import fs from 'node:fs';
import * as data from '../legacy/web/src/data.js';
import {initialState, plan, simulatePlan, craft, increment, collect, setCompletion, validateState, undo} from '../legacy/web/src/engine.js';
import {workbook,completionItems} from '../legacy/web/src/completion.js';
import {screenshotEvidence,screenshotFacts,applyScreenshotProgress} from '../legacy/web/src/screenshot-progress.js';
import {normalizeSlot,previewSaveImport,applySaveImport} from '../legacy/web/src/save-adapter.js';
const write=(name,value)=>fs.writeFileSync(name,JSON.stringify(value,null,2)+'\n');
write('assets/datasets/synthesis.json',data);
write('assets/datasets/completion.json',{...workbook,items:completionItems});
write('test/fixtures/evidence.json',{id:'achievements-screenshots-2026-10-09',items:screenshotEvidence,facts:screenshotFacts});
// Profilo di partenza della vecchia app (contiene progressi personali): solo per i
// fixture di parità. Il template dell'app, assets/datasets/initial-profile.json, è neutro.
write('test/fixtures/legacy-initial-profile.json',initialState());
fs.copyFileSync('legacy/web/public/KH1FM_Save_Analizzato.json','test/analyzed-save-2026-10-09.json');
const raw=JSON.parse(fs.readFileSync('legacy/web/public/KH1FM_Save_Analizzato.json'));
const base=initialState();
const scenarios=[['initial',base],['evidence',applyScreenshotProgress(base)],['no-rewards',{...base,plan:{...base.plan,rewards:{dark_matter:0,orichalcum:0}}}],['first-15',{...base,plan:{...base.plan,mode:'15'}}],['selected',{...base,plan:{...base.plan,mode:'selected',selected:['ultima_weapon']}}],['unknown-producers',{...base,inventory:{...base.inventory,dark_matter:null,mythril:null}}]];
write('test/parity-fixtures.json',{scenarios:scenarios.map(([name,state])=>({name,state,plan:plan(state),simulation:simulatePlan(state)})),snapshots:raw.slots.map(s=>normalizeSlot(raw,s.slot_number)),preview:previewSaveImport(base,raw,1),imported:applySaveImport(base,raw,1),operations:{crafted:craft(base,'cottage'),incremented:increment(base,'lucid_shard',5),collected:collect(base,data.collections[0].id,true),completed:setCompletion(base,completionItems[0].id,true)}});
console.log('Dati e fixture Flutter esportati.');
