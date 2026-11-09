import {useRef,useEffect} from 'react';
export function Icon({name,size=20}) {
 const paths={Save:'M4 3h14l3 3v15H3V3Z M7 3v6h9V3 M7 21v-8h10v8', 'Diario 100%':'M5 3h14v18H5Z M9 7h6 M9 11h6 M9 15h3',Checklist:'M9 5h12 M9 12h12 M9 19h12 M2 5l2 2 3-4 M2 12l2 2 3-4 M2 19l2 2 3-4',Guide:'M12 5C7 2 3 3 3 3v17s5-1 9 2c4-3 9-2 9-2V3s-4-1-9 2v17',down:'m6 9 6 6 6-6',up:'m6 15 6-6 6 6',Dashboard:'m3 10 9-7 9 7 M5 9v12h14V9 M9 21v-8h6v8',Inventario:'m3 7 9-5 9 5v10l-9 5-9-5Z M3 7l9 5 9-5 M12 12v10',Ricette:'M12 5C7 2 3 3 3 3v17s5-1 9 2c4-3 9-2 9-2V3s-4-1-9 2v17',Farming:'M4 20C4 10 11 4 21 3c0 10-5 16-12 16 M4 20l10-10',Collezionabili:'m3 7 4 5 5-8 5 8 4-5-2 13H5Z',Backup:'M4 6c0-5 16-5 16 0s-16 5-16 0v12c0 5 16 5 16 0V6 M4 12c0 5 16 5 16 0',Piano:'M5 4h14v17H5Z M9 8h6 M9 12h6 M9 16h4',Sessione:'m8 3 12 9-12 9Z',undo:'M4 10h9a7 7 0 1 1 0 14 M4 10l5-5 M4 10l5 5',search:'M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16 M16 16l6 6',check:'m5 12 4 4 10-10'};
 return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d={paths[name]||paths.check}/></svg>;
}
export function RepeatButton({direction,label,onStep,disabled}) {
 const timer=useRef(),interval=useRef(),active=useRef(false),step=useRef(onStep);step.current=onStep;
 function stop(){active.current=false;clearTimeout(timer.current);clearInterval(interval.current);}
 useEffect(()=>{window.addEventListener('pointerup',stop);window.addEventListener('blur',stop);return()=>{stop();window.removeEventListener('pointerup',stop);window.removeEventListener('blur',stop);};},[]);
 return <button className="arrow" aria-label={label} disabled={disabled} onPointerDown={e=>{if(e.button!==0)return;e.preventDefault();stop();active.current=true;step.current();timer.current=setTimeout(()=>{interval.current=setInterval(()=>{if(active.current)step.current();},90);},350);}} onPointerUp={stop} onPointerLeave={stop} onPointerCancel={stop} onClick={e=>{if(e.detail===0)step.current();}}><span aria-hidden="true">{direction==='up'?'+':'−'}</span><Icon name={direction} size={12}/></button>;
}
export function QuantityControl({name,value,set,add}) {
 return <div className={`quantity ${value===null?'unknown':''}`}>
 <RepeatButton direction="down" label={`Diminuisci ${name}`} disabled={value===null} onStep={()=>add(-1)}/>
 <input aria-label={`Quantità ${name}`} type="number" inputMode="numeric" min="0" max="999999" step="1" placeholder="?" value={value??''} onChange={e=>{const v=e.target.value;if(v==='')set(null);else if(/^\d+$/.test(v)&&Number.isSafeInteger(Number(v))&&Number(v)<=999999)set(Number(v));}} onKeyDown={e=>{if(['.','-','+','e','E',','].includes(e.key))e.preventDefault();if(e.key==='ArrowUp'||e.key==='ArrowDown'){e.preventDefault();if(value!==null)add(e.key==='ArrowUp'?1:-1);}}}/>
 <RepeatButton direction="up" label={`Aumenta ${name}`} disabled={value===null} onStep={()=>add(1)}/>
 <button className="quick" disabled={value===null} onClick={()=>add(5)}>+5</button><button className="quick" disabled={value===null} onClick={()=>add(10)}>+10</button>
 </div>;
}
export const Badge=({type='',children})=><span className={`badge ${type}`}>{children}</span>;
export function SourceLink({page,url}) {return <span className="sources"><a href={`/KH1_Final_Mix_Sintesi_Tracking.pdf#page=${page}`} target="_blank" rel="noreferrer">PDF · p. {page}</a>{url&&<> · <a href={url} target="_blank" rel="noreferrer">Guida ↗</a></>}</span>;}
