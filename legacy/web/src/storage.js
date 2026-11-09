import { initialState,validateState } from './engine.js';
import {applyScreenshotProgress} from './screenshot-progress.js';
export const STORAGE_KEY='kh1fm.profile.v1';
export const BACKUP_KEY='kh1fm.before-import.v1';
export function loadProfile(){if(shared)return serverState;const saved=localStorage.getItem(STORAGE_KEY);if(!saved)return initialState();return validateState(JSON.parse(saved));}
export function saveProfile(s){if(shared)return persistShared(s);localStorage.setItem(STORAGE_KEY,JSON.stringify(s));}
export function downloadJson(s,name='kh1fm-backup'){const blob=new Blob([JSON.stringify(s,null,2)],{type:'application/json'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download=`${name}-${new Date().toISOString().slice(0,10)}.json`;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}
export function importProfile(current,next){if(!shared)localStorage.setItem(BACKUP_KEY,JSON.stringify(current));downloadJson(current,'kh1fm-prima-importazione');if(shared)return persistShared(next,true).then(()=>next);saveProfile(next);return next;}

let shared=false,serverState,serverRevision=null;
export async function initializeStorage(){
 const response=await fetch('/api/profile',{cache:'no-store'});
 const result=await response.json();if(!response.ok)throw Error(result.error||'Archivio del progetto non disponibile.');
 serverRevision=result.revision;
 // A new shared archive starts empty: import the latest browser backup explicitly.
 serverState=result.state===null?initialState():validateState(result.state);shared=true;
 const updated=applyScreenshotProgress(serverState);
 if(result.state===null||updated!==serverState)await persistShared(updated);
}
async function persistShared(state,backup=false){
 const response=await fetch('/api/profile',{method:'PUT',headers:{'Content-Type':'application/json'},body:JSON.stringify({state,revision:serverRevision,backup})});
 const result=await response.json();if(!response.ok)throw Error(result.error||'Salvataggio non completato.');serverRevision=result.revision;serverState=state;
}
export function exportBrowserProfile(){const raw=localStorage.getItem(STORAGE_KEY);if(!raw)throw Error('Nessun salvataggio precedente in questo browser.');downloadJson(validateState(JSON.parse(raw)),'kh1fm-browser');}
