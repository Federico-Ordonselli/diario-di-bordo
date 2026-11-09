import {useState,useRef,useMemo,useEffect} from 'react';
import {initialState,plan,distinctCount,undo} from './engine.js';
import {loadProfile,saveProfile,importProfile} from './storage.js';
import {Icon} from './components.jsx';
import Inventory from './Inventory.jsx';
import Recipes from './Recipes.jsx';
import Planning,{PlanSelector} from './Planning.jsx';
import Farming,{MaterialPanel} from './Farming.jsx';
import Collections from './Collections.jsx';
import Dashboard,{NextSteps} from './Dashboard.jsx';
import Settings from './Settings.jsx';
import Backup from './Backup.jsx';
import {CompletionDashboard,CompletionChecklist,CompletionGuides} from './Completion.jsx';
import {completionSummary} from './completion.js';
import {applyScreenshotProgress} from './screenshot-progress.js';
import SaveImport from './SaveImport.jsx';
import {applySaveImport} from './save-adapter.js';
const nav=['Diario 100%','Checklist','Guide','Save','Dashboard','Inventario','Ricette','Farming','Collezionabili','Piano','Sessione','Backup'];
const subtitles={'Diario 100%':'Tutto il viaggio, un obiettivo alla volta.',Checklist:'Luoghi, requisiti e ricompense per ogni obiettivo.',Guide:'Le informazioni dell’Excel, sempre a portata di mano.',Save:'Snapshot, differenze e provenienza del tuo salvataggio.',Dashboard:'Il tuo salvataggio, una sintesi alla volta.',Inventario:'Aggiorna le scorte mentre giochi.',Ricette:'Tutte le 33 ricette, dagli accessori a Ultima Weapon.',Farming:'Organizza le raccolte per mondo.',Collezionabili:'Ricompense uniche, senza supposizioni.',Piano:'Scorte, produzioni e ricompense: un solo calcolo.',Sessione:'Una lista di raccolte per la sessione di gioco.',Backup:'Conserva e trasferisci i tuoi progressi.'};
const desktop=new URLSearchParams(location.search).has('desktop');
// Il server avviato dal launcher esce e il launcher chiude la finestra; altrimenti prova a chiuderla il browser.
async function quitApp(){try{const r=await fetch('/api/desktop/quit',{method:'POST'});if(r.ok)return;}catch{}window.close();}
function boot(){try{const previous=loadProfile(),state=applyScreenshotProgress(previous);return {state,error:''};}catch(e){return {state:initialState(),error:`Il salvataggio locale non è leggibile: ${e.message} I dati originali restano nel browser. Importa un backup per ripristinare il profilo.`};}}
export default function App() {
 const [loaded]=useState(boot),[state,setState]=useState(loaded.state),[view,setView]=useState('Diario 100%'),[error,setError]=useState(''),[saveError,setSaveError]=useState(loaded.error),[selectedMaterial,setSelectedMaterial]=useState(null);
 const [checklistCategory,setChecklistCategory]=useState('all'),[guideId,setGuideId]=useState('tips');
 const overall=completionSummary(state),completionView=['Diario 100%','Checklist','Guide','Save'].includes(view);
 const saving=useRef(false);
 const stateRef=useRef(state),blocked=useRef(!!loaded.error);
 const p=useMemo(()=>plan(state),[state]);
 async function commit(next){await saveProfile(next);stateRef.current=next;setState(next);setSaveError('');}
 async function update(action){if(saving.current)return;saving.current=true;try{if(blocked.current)throw Error('Ripristina prima il profilo dalla pagina Backup.');const next=action(stateRef.current);if(next===stateRef.current)return;await commit(next);setError('');}catch(e){setError(e.message);}finally{saving.current=false;}}
 async function handleImport(next){if(saving.current)return false;saving.current=true;try{const imported=await importProfile(stateRef.current,next);blocked.current=false;stateRef.current=imported;setState(imported);setError('');setSaveError('');return true;}catch(e){setError(`Importazione non completata: ${e.message}`);return false;}finally{saving.current=false;}}
 async function handleSaveImport(raw,slot,decisions){try{if(blocked.current)throw Error('Ripristina prima il profilo dalla pagina Backup.');return await handleImport(applySaveImport(stateRef.current,raw,slot,decisions));}catch(e){setError(e.message);return false;}}
 function navigate(v){setView(v);setSelectedMaterial(null);window.scrollTo(0,0);}
 function openCategory(id){if(id==='recipes'){navigate('Ricette');return;}setChecklistCategory(id);navigate('Checklist');}
 function openGuide(id){setGuideId(id);navigate('Guide');}
 useEffect(()=>{const fn=e=>{if(e.key==='Escape')setSelectedMaterial(null);};window.addEventListener('keydown',fn);return()=>window.removeEventListener('keydown',fn);},[]);
 useEffect(()=>{const fn=e=>{if(e.key==='kh1fm.profile.v1'){blocked.current=true;setSaveError('Il profilo è cambiato in un’altra scheda. Ricarica questa pagina prima di continuare.');}};window.addEventListener('storage',fn);return()=>window.removeEventListener('storage',fn);},[]);
 return <div className="app-shell"><aside className="sidebar"><div className="brand"><svg className="brand-mark" viewBox="0 0 40 36" fill="currentColor" aria-hidden="true"><path d="M5 9 13 18 20 3 27 18 35 9 31 29H9Z"/><path d="M9 31h22v3H9z"/></svg><div><strong>Diario</strong><small>Kingdom Hearts Final Mix</small></div></div><nav aria-label="Navigazione principale">{nav.map(v=><button key={v} aria-current={view===v?'page':undefined} className={`${view===v?'active ':''}${v==='Dashboard'?'synthesis-nav-start':''}`} onClick={()=>navigate(v)}><Icon name={v}/><span>{v}</span></button>)}</nav><div className="sidebar-bottom"><small>Il tuo salvataggio</small><strong>{state.activeSaveId?state.saveSnapshots[state.activeSaveId].location.save_label:'End of the World'}</strong><a href="/KH1_Final_Mix_Sintesi_Tracking.pdf" target="_blank" rel="noreferrer">Dossier di gioco ↗</a><span className="local-dot">Locale · nessun account</span></div></aside><main className={view==='Inventario'?'with-aside':''}><div className="main-content"><header><div><h1>{view}</h1><p>{subtitles[view]}</p></div><div className="header-progress"><strong>{completionView?overall.done:distinctCount(state)}</strong><span>{completionView?` / ${overall.total} voci`:' / 33 sintetizzate'}</span></div></header><div className="utility"><span className={saveError?'gold':'save-label'}>{saveError?'Salvataggio da verificare':'● Salvataggio automatico'}{!saveError&&<small> · {new Date(state.updatedAt).toLocaleTimeString('it-IT',{hour:'2-digit',minute:'2-digit'})}</small>}</span><div className="utility-actions"><button className="undo" disabled={!state.transactions.length} title={state.transactions.at(-1)?.label} onClick={()=>update(undo)}><Icon name="undo" size={16}/>Annulla ultima operazione</button>{desktop&&<button className="undo quit" title="Chiude la finestra e ferma il server locale" onClick={()=>{if(!saving.current)quitApp();}}>⏻ Chiudi app</button>}</div></div>{saveError&&<div className="alert" role="alert">{saveError}</div>}{error&&<div className="alert" role="alert">{error}<button onClick={()=>setError('')} aria-label="Chiudi messaggio">×</button></div>}
 {!completionView&&view!=='Backup'&&<PlanSelector state={state} update={update}/>}
 {view==='Diario 100%'&&<CompletionDashboard state={state} onCategory={openCategory} onGuide={openGuide}/>}
 {view==='Checklist'&&<CompletionChecklist state={state} update={update} categoryId={checklistCategory} onCategory={openCategory} onGuide={openGuide}/>}
 {view==='Guide'&&<CompletionGuides guideId={guideId} onGuide={openGuide} onCategory={openCategory}/>}
 {view==='Save'&&<SaveImport state={state} update={update} onApply={handleSaveImport}/>}
 {view==='Inventario'&&<Inventory state={state} update={update} p={p} onMaterial={setSelectedMaterial}/>}
 {view==='Dashboard'&&<Dashboard state={state} p={p} navigate={navigate} onMaterial={setSelectedMaterial}/>}
 {view==='Ricette'&&<Recipes state={state} update={update}/>}
 {view==='Piano'&&<Planning state={state} update={update} p={p}/>}
 {(view==='Farming'||view==='Sessione')&&<><Farming state={state} update={update} p={p} session={view==='Sessione'}/><Settings state={state} update={update}/></>}
 {view==='Collezionabili'&&<Collections state={state} update={update}/>}
 {view==='Backup'&&<Backup state={state} onImport={handleImport}/>}
 </div>{view==='Inventario'&&<NextSteps state={state} navigate={navigate}/>}</main>{selectedMaterial&&<MaterialPanel id={selectedMaterial} state={state} update={update} p={p} close={()=>setSelectedMaterial(null)}/>}</div>;
}
