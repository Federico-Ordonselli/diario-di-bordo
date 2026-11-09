// Server locale per la build già pronta. Non richiede pacchetti esterni.
import {profileApi} from './profile-server.mjs';
import {createServer} from 'node:http';
import {readFile,stat} from 'node:fs/promises';
import {resolve,extname,sep} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('./dist/',import.meta.url));
const types={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.pdf':'application/pdf','.json':'application/json','.png':'image/png','.svg':'image/svg+xml'};
// Avviato da scripts/desktop/launch.sh: il pulsante «Chiudi app» spegne il server e il launcher chiude la finestra.
const desktop=process.env.KH_DESKTOP==='1';
try{await stat(resolve(root,'index.html'));}catch{console.error('Build assente. Esegui npm install e npm run build.');process.exit(1);}
const server=createServer(async(req,res)=>{
 if(desktop&&req.method==='POST'&&req.url==='/api/desktop/quit'){
  if(req.headers.origin!==`http://${req.headers.host}`){res.writeHead(403);return res.end();}
  res.writeHead(204);return res.end(()=>process.exit(0));
 }
 await profileApi(req,res,async()=>{
 try{
  if(!['GET','HEAD'].includes(req.method)){res.writeHead(405);return res.end();}
  const pathname=decodeURIComponent(new URL(req.url,'http://127.0.0.1').pathname);
  const file=resolve(root,'.'+(pathname==='/'?'/index.html':pathname));
  if(!file.startsWith(resolve(root)+sep)){res.writeHead(403);return res.end();}
  const data=await readFile(file);res.writeHead(200,{'Content-Type':types[extname(file)]||'application/octet-stream','Cache-Control':'no-cache'});res.end(req.method==='HEAD'?undefined:data);
 }catch{res.writeHead(404,{'Content-Type':'text/plain; charset=utf-8'});res.end('File non trovato.');}
 });
});
server.on('error',e=>{console.error(e.code==='EADDRINUSE'?'Porta 5173 già occupata. Ferma l’altra istanza (Ctrl+C) e riprova.':e.message);process.exit(1);});
server.listen(5173,'127.0.0.1',()=>console.log('Tracker locale pronto: http://127.0.0.1:5173\nLascia aperto questo terminale. Ctrl+C per fermarlo.'));
