import {useMemo,useState} from 'react';
import {categories,completionItems,completionSummary,isCompleted,completionStatus,workbook} from './completion.js';
import {setCompletion} from './engine.js';
import {SaveProvenance} from './SaveImport.jsx';
import {screenshotEvidenceById,screenshotFacts,screenshotSources,screenshotImportId} from './screenshot-progress.js';

const familyOrder=['Diario di Grillo','Raccolta','Sfide','Equipaggiamento','Gummiship','Trofei'];
const columnLabels={Rarity:'Rarità','Trophy/Achievement':'Trofeo','Description':'Descrizione',Tournament:'Torneo','Unlock requirements':'Requisiti','Reward':'Ricompensa',Item:'Oggetto','How to get it':'Come ottenerlo','Journal Entry':'Voce del diario','How to obtain it':'Come sbloccarlo','No.':'Numero',World:'Mondo',Area:'Area',Location:'Posizione',Minigame:'Minigioco','Where to find it':'Dove trovarlo',Recipe:'Ricetta',Blueprint:'Progetto','Mission #':'Missione',Price:'Prezzo','Spell / Summon':'Magia / evocazione',Effect:'Effetto'};
const descriptionColumns={achievements:'E',coliseum:'C',reports:'C',characters:'C',dalmatians:'E',minigames:'C',trinities:'E',treasures:'D',blueprints:'C',missions:'C',keyblades:'G',staves:'F',shields:'F',magic:'D'};
const categoryById=Object.fromEntries(categories.map(c=>[c.id,c]));

export function WorkbookLinks({links,onCategory,onGuide}) {
 return <div className="workbook-links">{links.map((link,i)=>link.url?<a key={i} href={link.url} target="_blank" rel="noreferrer">{link.label==='Guida'?'Guida ↗':`${link.label} ↗`}</a>:link.category?<button key={i} className="text-button" onClick={()=>onCategory(link.category)}>Apri {categoryById[link.category]?.label} →</button>:link.guide?<button key={i} className="text-button" onClick={()=>onGuide(link.guide)}>Apri materiali →</button>:null)}</div>;
}

export function CompletionDashboard({state,onCategory,onGuide}) {
 const summary=completionSummary(state);
 return <>
  <section className="completion-overview" aria-label="Progresso complessivo">
   <div className="completion-score"><strong>{summary.percent.toLocaleString('it-IT')}<span>%</span></strong><div><h2>Il viaggio verso il 100%</h2><p>{summary.done} voci completate · {summary.remaining} ancora da completare</p></div></div>
   <progress aria-label="Voci della checklist completate" value={summary.done} max={summary.total}/>
   <p className="footnote">La percentuale misura le {summary.total} voci dell’Excel, incluse le 33 sintesi. Trofei e attività restano distinti; non è una percentuale ufficiale del gioco. I dalmata si contano per gruppo di tre.</p>
  </section>
  <h2>Il tuo percorso</h2>
  {state.appliedEvidence?.includes(screenshotImportId)&&<details className="workbook-note"><summary>Progressi dagli screenshot · 21 achievement confermati</summary>{screenshotFacts.map(fact=><p key={fact}>{fact}</p>)}<small>Fonti: {screenshotSources.join(' · ')}</small><p><a href="https://www.khguides.com/kh/inventory/journal/" target="_blank" rel="noreferrer">Verifica gli sblocchi del diario su KHGuides ↗</a></p></details>}
  <div className="completion-path">{familyOrder.map(family=><section className="completion-family" key={family}><h3>{family}</h3>{categories.filter(c=>c.family===family).map(category=>{
   const count=completionSummary(state,category.id);
   return <button className="category-row" key={category.id} onClick={()=>onCategory(category.id)}><span>{category.label}</span><span className="category-progress"><span>{count.done} / {count.total}</span><progress aria-label={`Progresso ${category.label}`} value={count.done} max={count.total}/></span><span className="category-arrow" aria-hidden="true">→</span></button>;
  })}</section>)}</div>
  <section className="completion-source"><h2>Le tue guide</h2><p>Requisiti, luoghi e ricompense sono quelli del file originale. Il testo delle guide resta in inglese, i comandi dell’app sono in italiano.</p><div className="filters"><button onClick={()=>onGuide('tips')}>Consigli e boss segreti</button><button onClick={()=>onGuide('materials')}>Materiali di sintesi</button><a href={workbook.download} download>Scarica Excel originale ↗</a></div></section>
 </>;
}

export function CompletionChecklist({state,update,categoryId,onCategory,onGuide}) {
 const [search,setSearch]=useState(''),[status,setStatus]=useState('all'),[world,setWorld]=useState(''),[group,setGroup]=useState(''),[limit,setLimit]=useState(40);
 const category=categoryById[categoryId];
 const pool=useMemo(()=>category?completionItems.filter(item=>item.categoryId===category.id):completionItems,[category]);
 const worlds=useMemo(()=>[...new Set(pool.map(item=>item.world).filter(Boolean))],[pool]);
 const groups=useMemo(()=>[...new Set(pool.map(item=>item.group).filter(Boolean))],[pool]);
 const visible=useMemo(()=>pool.filter(item=>(status==='all'||completionStatus(state,item)===status)&&(!world||item.world===world)&&(!group||item.group===group)&&`${item.title} ${item.categoryLabel} ${item.group} ${Object.values(item.fields).join(' ')} ${item.comments.join(' ')}`.toLowerCase().includes(search.toLowerCase().trim())),[pool,status,state,world,group,search]);
 const summary=completionSummary(state,category?.id);
 function choose(id){setWorld('');setGroup('');setLimit(40);onCategory(id);}
 function filter(set,value){set(value);setLimit(40);}
 return <>
  <div className="checklist-heading"><div><h2>{category?.label||'Tutte le categorie'}</h2><p>{summary.done} / {summary.total} completate</p></div><select aria-label="Categoria della checklist" value={categoryId} onChange={e=>choose(e.target.value)}><option value="all">Tutte le categorie</option>{familyOrder.map(family=><optgroup key={family} label={family}>{categories.filter(c=>c.family===family).map(c=><option key={c.id} value={c.id}>{c.label} ({c.items.length})</option>)}</optgroup>)}</select></div>
  <p className="hint">Spunta ciò che hai già completato. Ogni modifica si salva e si può annullare. Le nuove voci non spuntate nell’Excel restano da completare finché le confermi.</p>
  {category?.id==='synthesis'&&<p className="checklist-notice">Queste spunte correggono lo storico della sintesi e i suoi sblocchi, senza consumare materiali. Per creare un oggetto con le scorte usa <button className="text-button" onClick={()=>onCategory('recipes')}>Ricette →</button>.</p>}
  {category?.id==='achievements'&&<p className="checklist-notice">Trofei segnati manualmente: alcune condizioni dipendono dalla piattaforma o richiedono una partita dedicata. Completare una raccolta non sblocca automaticamente il trofeo nell’app.</p>}
  {category&&<WorkbookLinks links={category.notes.flatMap(note=>note.links).filter(link=>link.url)} onCategory={choose} onGuide={onGuide}/>}
  {category?.notes.map((note,i)=><details className="workbook-note" key={i}><summary>Nota della guida{category.notes.length>1?` ${i+1}`:''}</summary><p>{note.text}</p><WorkbookLinks links={note.links} onCategory={choose} onGuide={onGuide}/></details>)}
  <div className="toolbar checklist-toolbar"><div className="search"><input aria-label="Cerca nella checklist" placeholder="Cerca nome, luogo, ricompensa o requisito…" value={search} onChange={e=>filter(setSearch,e.target.value)}/></div><select aria-label="Filtra stato" value={status} onChange={e=>filter(setStatus,e.target.value)}><option value="all">Tutti gli stati</option><option value="todo">Da completare</option><option value="done">Completati</option><option value="unknown">Da verificare</option></select>{worlds.length>0&&<select aria-label="Filtra mondo" value={world} onChange={e=>filter(setWorld,e.target.value)}><option value="">Tutti i mondi</option>{worlds.map(w=><option key={w}>{w}</option>)}</select>}{groups.length>1&&!worlds.length&&<select aria-label="Filtra gruppo" value={group} onChange={e=>filter(setGroup,e.target.value)}><option value="">Tutti i gruppi</option>{groups.map(g=><option key={g}>{g}</option>)}</select>}</div>
  <p className="checklist-result" role="status">{visible.length} voci trovate · {Math.min(limit,visible.length)} mostrate</p>
  <div className="checklist-list">{visible.slice(0,limit).map(item=>{
   const done=isCompleted(state,item),unknown=completionStatus(state,item)==='unknown',sourceCategory=categoryById[item.categoryId],descriptionKey=descriptionColumns[item.categoryId],description=item.fields[descriptionKey];
   const fields=sourceCategory.columns.filter(c=>c.key!==descriptionKey&&c.key!==(item.categoryId==='achievements'?'D':'B')&&item.fields[c.key]&&item.fields[c.key]!=='-');
   return <article className={`checklist-item${done?' is-complete':''}`} key={item.id}>
    <div className="checklist-item-top"><label className="completion-toggle"><input type="checkbox" aria-label={`Completa ${item.title}`} checked={done} onChange={e=>update(s=>setCompletion(s,item.id,e.target.checked))}/><span>{item.title}</span></label><span className={`completion-state${done?' green':''}`}>{unknown?'Da verificare':done?'Completato':'Da completare'}</span>{!item.recipeId&&<select className="save-state-select" aria-label={`Conferma stato ${item.title}`} value={unknown?'unknown':done?'done':'todo'} onChange={e=>update(s=>setCompletion(s,item.id,e.target.value==='unknown'?null:e.target.value==='done'))}><option value="done">Completato</option><option value="todo">Da completare</option><option value="unknown">Da verificare</option></select>}</div>
    <div className="checklist-item-content"><small>{item.categoryLabel}{item.group?` · ${item.group}`:''}{item.world&&item.world!==item.group?` · ${item.world}`:''}</small>{description&&<p>{description}</p>}
     {fields.length>0&&<dl className="checklist-fields">{fields.map(col=><div key={col.key}><dt>{columnLabels[col.label]||col.label}</dt><dd>{item.fields[col.key]}</dd></div>)}</dl>}
     {item.comments.map((comment,i)=><p key={i} className="checklist-notice">{comment}</p>)}
     <WorkbookLinks links={item.links} onCategory={choose} onGuide={onGuide}/>
     <SaveProvenance state={state} target={`completion.${item.id}`}/><details className="item-source"><summary>Fonti e deduzioni</summary><small>Excel · {sourceCategory.sheet} · riga {item.row}</small>{state.appliedEvidence?.includes(screenshotImportId)&&screenshotEvidenceById[item.id]&&<><p>{screenshotEvidenceById[item.id].kind==='direct'?'Confermato dagli screenshot':'Dedotto dagli achievement'}: {screenshotEvidenceById[item.id].reason}</p><small>{screenshotSources.join(' · ')}</small></>}<a href={workbook.download} download>Scarica Excel</a></details>
    </div>
   </article>;
  })}</div>
  {!visible.length&&<p className="empty">Nessuna voce corrisponde ai filtri.</p>}
  {visible.length>limit&&<button className="load-more" onClick={()=>setLimit(n=>n+40)}>Mostra altre {Math.min(40,visible.length-limit)} voci ({visible.length-limit} rimanenti)</button>}
 </>;
}

export function CompletionGuides({guideId,onGuide,onCategory}) {
 const guide=workbook.guides.find(g=>g.id===guideId)||workbook.guides[0];
 const [search,setSearch]=useState('');
 const entries=useMemo(()=>guide.id==='materials'?guide.sections:guide.sections.reduce((result,section,index,all)=>{
  if(index%2===0)result.push({...section,title:section.text,text:all[index+1]?.text||'',links:[...section.links,...(all[index+1]?.links||[])]});
  return result;
 },[]),[guide]);
 const sections=entries.filter(s=>`${s.title||''} ${s.text}`.toLowerCase().includes(search.toLowerCase().trim()));
 return <><div className="guide-tabs filters">{workbook.guides.map(g=><button key={g.id} className={guide.id===g.id?'active':''} onClick={()=>{setSearch('');onGuide(g.id);}}>{g.label}</button>)}</div><h2>{guide.label}</h2><p>Contenuti e collegamenti estratti dall’Excel originale. Per strategie dettagliate di farming consulta anche la sezione Farming.</p><div className="toolbar"><div className="search"><input aria-label="Cerca nelle guide" placeholder="Cerca materiale, boss o consiglio…" value={search} onChange={e=>setSearch(e.target.value)}/></div></div><div className="guide-content">{sections.map(section=><article key={section.row} className="guide-entry">{guide.id==='materials'?<><h3>{section.fields.B}</h3><dl className="checklist-fields"><div><dt>Nemico / fonte</dt><dd>{section.fields.C}</dd></div><div><dt>Luogo</dt><dd>{section.fields.D}</dd></div></dl></>:<><h3>{section.title}</h3><p>{section.text}</p></>}<WorkbookLinks links={section.links} onCategory={onCategory} onGuide={onGuide}/><small>Excel · {guide.sheet} · riga {section.row}</small></article>)}</div>{!sections.length&&<p className="empty">Nessun risultato per questa ricerca.</p>}<a href={workbook.download} download>Scarica Excel originale ↗</a></>;
}
