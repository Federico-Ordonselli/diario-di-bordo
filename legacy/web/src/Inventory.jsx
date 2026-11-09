import {useState,useMemo} from 'react';
import {materials} from './data.js';
import {setQuantity,increment} from './engine.js';
import {SaveProvenance} from './SaveImport.jsx';
import {QuantityControl,Badge,Icon,SourceLink} from './components.jsx';
const filters=['Tutti','Da farmare','Già sufficienti','Da verificare'];
export default function Inventory({state,update,p,onMaterial}) {
 const [search,setSearch]=useState(''),[filter,setFilter]=useState('Tutti'),[membership,setMembership]=useState(null);
 // Filter membership changes only when the player requests it, never while holding an arrow.
 const visible=useMemo(()=>materials.filter(m=>m.name.toLowerCase().includes(search.toLowerCase())&&(!membership||membership.includes(m.id))),[search,membership]);
 function applyFilter(f){setFilter(f);setMembership(f==='Tutti'?null:materials.filter(m=>f==='Da verificare'?p.rows[m.id].unknown:f==='Già sufficienti'?p.rows[m.id].sufficient:p.rows[m.id].missing>0).map(m=>m.id));}
 return <>
 <div className="toolbar"><div className="search"><Icon name="search"/><input aria-label="Cerca un materiale" placeholder="Cerca un materiale…" value={search} onChange={e=>setSearch(e.target.value)}/></div><div className="filters">{filters.map(f=><button key={f} className={filter===f?'active':''} onClick={()=>applyFilter(f)}>{f}</button>)}</div></div>
 {p.uncertainDependencies.length>0&&<p className="gold">Mythril o Dark Matter da verificare: il fabbisogno è uno scenario prudente, i deficit dipendenti restano sconosciuti.</p>}
 <div className="table-wrap"><table className="inventory-table"><thead><tr><th>Materiale</th><th>Posseduti</th><th>Piano</th><th>Manca</th><th>Stato</th></tr></thead><tbody>{visible.map(m=>{const row=p.rows[m.id];return <tr key={m.id} data-material={m.id}><td><button className="material-name" onClick={()=>onMaterial(m.id)}>{m.name}</button><SaveProvenance state={state} target={`inventory.${m.id}`}/></td><td><QuantityControl name={m.name} value={state.inventory[m.id]} set={n=>update(s=>setQuantity(s,m.id,n))} add={n=>update(s=>increment(s,m.id,n))}/></td><td className="numeric">{row.external}</td><td className={`numeric ${row.missing>0?'gold':''}`}>{row.missing??'?'}</td><td><Badge type={row.unknown?'warn':row.sufficient?'good':'warn'}>{row.unknown?'Da verificare':row.sufficient?'Già sufficiente':'Da farmare'}</Badge>{row.planned>0&&<small className="reward-note">{row.planned} da ricompense</small>}</td></tr>;})}</tbody></table>{visible.length===0&&<p className="empty">Nessun materiale corrisponde alla ricerca.</p>}</div>
 <p className="footnote">{visible.length} / 34 materiali · Ordine fisso. I filtri si aggiornano al clic, così le righe restano ferme durante le modifiche. “Piano” indica il fabbisogno esterno, al netto della produzione. “Manca” include le ricompense ancora da raccogliere.</p><SourceLink page={2}/>
 </>;
}
