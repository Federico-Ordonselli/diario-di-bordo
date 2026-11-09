import {completionItems} from './completion.js';
import {transact} from './engine.js';

export const screenshotImportId='achievements-screenshots-2026-10-09';
export const screenshotSources=['Schermata_20261009_184652.png','Schermata_20261009_184725.png'];
const evidence=new Map();
function add(items,reason,kind='inferred') {
 for(const item of items)evidence.set(item.id,{id:item.id,title:item.title,categoryId:item.categoryId,reason,kind});
}
function select(categoryId,titles) {
 const items=titles.map(title=>completionItems.find(item=>item.categoryId===categoryId&&item.title===title));
 if(items.some(item=>!item))throw Error(`Voce non trovata nella categoria ${categoryId}.`);
 return items;
}
const unlocked=[
 'Top Dog','Artisan Hero','Novice Hero','Top Gun','End of the World','Oathkeeper',
 'Junior Hero','Hero of the Coliseum','First Synthesis','Heartless Hunter','Pixie Dust',
 'Master of the Seas','Treasure Hunter','Pumpkin Prince','Honest Soul','Magic Lamp',
 'Where the Bells Toll','Member of the Tribe','The Rabbit Hole','Customizer','Test Pilot',
];
add(select('achievements',unlocked),'Achievement visibile come sbloccato negli screenshot.','direct');
add(completionItems.filter(item=>item.categoryId==='dalmatians'),'Top Dog conferma tutte le voci dei dalmata.');
add(completionItems.filter(item=>item.categoryId==='treasures'&&/^(Dalmatians|Puppies) \(/.test(item.title)),'Top Dog conferma anche la raccolta dei gruppi di dalmata in queste fonti specifiche.');
add(completionItems.filter(item=>item.categoryId==='trinities'&&/Dalmatians|Puppies/i.test(item.fields.F)),'Top Dog conferma i marchi Trio necessari a raccogliere questi dalmata, come indicato nell’Excel.');
add(select('trinities',['Trinity Push · 2']),'Junior Hero conferma la serratura del Monte Olimpo, sigillata con questo marchio Trio.');
add(select('coliseum',['Phil Cup (Standard)','Pegasus Cup (Standard)','Hercules Cup (Standard)']),'Novice Hero, Artisan Hero e Hero of the Coliseum confermano le coppe standard. Le varianti Solo e Time Trial non sono deducibili.');
add(select('keyblades',['Oathkeeper']),'Oathkeeper conferma direttamente l’ottenimento del Keyblade.');
add(select('keyblades',['Jungle King','Three Wishes','Crabclaw','Pumpkinhead','Fairy Harp']),'Ricompensa della serratura del relativo mondo, confermata dall’achievement e dalla condizione nell’Excel.');
add(select('keyblades',['Metal Chocobo']),'La coppa Ercole standard completata comprende la vittoria su Cloud, che assegna Metal Chocobo.');
add(select('keyblades',['Kingdom Key']),'Arma iniziale necessaria per la progressione della storia confermata dagli screenshot.');
add(select('staves',["Mage's Staff"]),'Arma iniziale di Paperino; la storia avanzata è confermata dagli screenshot.');
add(select('shields',["Knight's Shield","Herc's Shield"]),'Scudo iniziale di Pippo e ricompensa della coppa Ercole standard confermata.');
add(select('reports',['Ansem Report 1','Ansem Report 3','Ansem Report 5','Ansem Report 7','Ansem Report 9']),'Rapporto assegnato dalla storia nel relativo mondo completato, secondo l’Excel. I rapporti che richiedono parlare ad Aerith restano da verificare.');
add(select('magic',['Fire','Fira','Firaga','Blizzard','Blizzara','Thunder','Thundara','Cure','Cura','Gravity','Gravira','Stop','Aero','Genie','Tinker Bell']),'Sblocco o potenziamento assegnato dalla storia dei mondi e dalla coppa Fil confermati. Non sono inclusi oggetti in forzieri o gemme da consegnare.');
add(select('blueprints',['Kingdom']),'Progetto iniziale della Gummiship; Top Gun e Customizer ne confermano l’utilizzo.');
// Only explicit story entries before the optional 100 Acre Wood section.
// A journal entry's presence does not imply every later text update is complete.
add(completionItems.filter(item=>item.categoryId==='characters'&&item.fields.C==='Obtained during the story.'&&item.row<=101&&!['Merlin','Fairy Godmother'].includes(item.title)),
 'Voce assegnata durante la storia dei mondi completati e visibili negli screenshot. Esclusi finale e Bosco dei 100 Acri.');
add(select('characters',['Hades','Pinocchio','Geppetto']),
 'KHGuides conferma la prima voce durante i preliminari del Monte Olimpo o la visita della storia a Monstro; non si presume il successivo aggiornamento del diario.');
add(select('characters',['Guard Armor','Opposite Armor','Trickmaster','Stealth Sneak','Pot Centipede','Parasite Cage','Shadow','Darkside','Behemoth']),
 'Nemico della storia già completata: la voce è automatica secondo l’Excel.');
add(select('characters',['Red Armor']),'Presente nella coppa Fil standard confermata da Novice Hero.');

export const screenshotEvidence=[...evidence.values()];
export const screenshotEvidenceById=Object.fromEntries(screenshotEvidence.map(item=>[item.id,item]));
export const screenshotFacts=[
 '21 achievement risultano sbloccati nei due screenshot.',
 'Treasure Hunter conferma almeno 100 forzieri aperti. Si identificano solo le fonti dei dalmata; gli altri forzieri restano da verificare.',
 'Top Gun conferma tutte le rotte Gummi. Test Pilot conferma l’achievement di livello 1, ma non identifica una missione dell’Excel: nessuna missione specifica viene spuntata.',
 'Heartless Hunter conferma oltre 2.000 Heartless sconfitti, senza identificare tutti i tipi incontrati.',
 'Olimpia richiede aprire il forziere; Curaga e vari rapporti richiedono parlare ad Aerith. Queste azioni non risultano dagli screenshot.',
 'Gli sblocchi certi sono storici: non indicano scorte attuali, equipaggiamento attivo o ricompense già ritirate.',
];

export function applyScreenshotProgress(state) {
 if(state.appliedEvidence?.includes(screenshotImportId))return state;
 return transact(state,'Progressi dagli screenshot: 21 achievement e sblocchi certi',next=>{
  for(const item of screenshotEvidence)next.completion[item.id]=true;
  next.appliedEvidence=[...(next.appliedEvidence||[]),screenshotImportId];
  // Availability is proven by actual use of the puppy-related trinity marks.
  next.settings['Trio Bianco']=true;next.settings['Trio Giallo']=true;next.settings.Stop=true;
 },'evidence');
}
