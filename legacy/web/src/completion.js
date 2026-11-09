import workbook from './completion-data.json' with {type:'json'};
import {recipes} from './data.js';

export {workbook};
export const categories = workbook.categories;
const normalize = name => name.toLowerCase().replace(/[^a-z0-9]+/g,'_').replace(/^_|_$/g,'');
const recipeNames = Object.fromEntries(recipes.map(r=>[normalize(r.name),r.id]));
export const completionItems = categories.flatMap(category=>category.items.map(item=>({
 ...item, categoryId:category.id, categoryLabel:category.label,
 recipeId:category.id==='synthesis'?recipeNames[normalize(item.title)]:undefined,
})));
export const completionById = Object.fromEntries(completionItems.map(item=>[item.id,item]));
export const initialCompletion = () => Object.fromEntries(completionItems.filter(item=>!item.recipeId&&item.initialDone).map(item=>[item.id,true]));
export const isCompleted = (state,item) => item.recipeId?!!state.everCrafted[item.recipeId]:!!state.completion?.[item.id];
export const completionStatus=(state,item)=>!item.recipeId&&Object.hasOwn(state.completion,item.id)&&state.completion[item.id]===null?'unknown':isCompleted(state,item)?'done':'todo';
export function completionSummary(state,categoryId) {
 const items=categoryId?completionItems.filter(item=>item.categoryId===categoryId):completionItems;
 const done=items.filter(item=>isCompleted(state,item)).length;
 return {done,total:items.length,remaining:items.length-done,percent:items.length?Math.round(done/items.length*1000)/10:0};
}
export function validateCompletion(raw,legacy=false) {
 const result=initialCompletion();
 if(legacy&&raw===undefined)return result;
 if(!raw||typeof raw!=='object'||Array.isArray(raw))throw Error('Checklist 100% non valida.');
 for(const [id,done] of Object.entries(raw)) {
  const item=Object.hasOwn(completionById,id)?completionById[id]:undefined;
  if(!item||item.recipeId)throw Error('Il backup contiene voci di checklist non riconosciute.');
  if(typeof done!=='boolean'&&done!==null)throw Error(`Completamento non valido: ${item.title}`);
  result[id]=done;
 }
 return result;
}
