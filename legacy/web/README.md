# Kingdom Hearts 1 Final Mix — Diario 100%

App personale locale per seguire il completamento di Kingdom Hearts Final Mix. Interfaccia in italiano, nomi e descrizioni dell’Excel in inglese. Fonti: `Copia di Guide & Checklist — Kingdom Hearts Final Mix.xlsx` e `KH1_Final_Mix_Sintesi_Tracking.pdf`. Nessun account o servizio remoto. La build pronta in `dist/` include Excel, PDF e tutte le risorse.

## Diario e checklist del 100%

La schermata iniziale **Diario 100%** mostra il progresso totale e quello delle 15 categorie. Sono presenti tutte le **794 voci** dell’Excel: 56 trofei, 14 tornei, 13 rapporti di Ansem, 160 voci del diario tra personaggi e nemici, 33 gruppi di dalmata, 18 minigiochi, 46 marchi Trio, 268 tesori, 33 sintesi, 48 progetti Gummi, 30 missioni Gummi, 18 Keyblade, 15 bastoni, 15 scudi e 27 magie/evocazioni.

- Apri una categoria dal Diario oppure usa **Checklist** per cercare in tutte le categorie. Filtra per stato, mondo o gruppo. I risultati lunghi si caricano 40 alla volta.
- Ogni voce conserva requisiti, luogo, ricompense, statistiche, commenti e riferimenti alla riga originale. Le note dell’Excel includono condizioni particolari e i collegamenti alle guide esterne; i collegamenti interni aprono la categoria pertinente.
- Le spunte indicano attività già completate. Si salvano automaticamente e **Annulla ultima operazione** le ripristina. Spuntare un tesoro non modifica automaticamente l’inventario dei materiali o le previsioni del piano di sintesi.
- Le 33 ricette condividono `everCrafted` con il laboratorio: spuntarle corregge lo storico senza consumare materiali. Anche le creazioni effettuate nel laboratorio aggiornano il Diario. Non esiste un secondo contatore di sintesi.
- La percentuale conta le voci spuntate nel file: non è una misura ufficiale del gioco. Trofei e attività sono indipendenti, i dalmata si contano per gruppo di tre e i minigiochi facoltativi restano inclusi come nell’Excel. I trofei vengono confermati manualmente.
- **Guide** raccoglie fonti dei 34 materiali, consigli per salire di livello, partite per trofei particolari, boss segreti e Torn Pages. Puoi scaricare l’Excel originale dall’app.

Le voci non spuntate nell’Excel partono da completare; l’app non deduce progressi personali dal testo delle guide. Lo storico di sintesi già salvato rimane valido.

## Progressi dagli screenshot degli achievement

I due screenshot `Schermata_20261009_184652.png` e `Schermata_20261009_184725.png` confermano 21 achievement. Alla prossima apertura l’app unisce ai progressi esistenti gli achievement e gli sblocchi identificabili: dalmata e relative fonti, Trio necessari, coppe standard, armi e magie obbligatorie, rapporti di Ansem della storia e voci del diario. Le condizioni del diario sono state confrontate anche con KHGuides, perché alcune righe dell’Excel confondono la prima acquisizione con aggiornamenti successivi.

L’importazione è una sola operazione annullabile e non modifica inventario, storico di sintesi o ricompense previste. Il marcatore `appliedEvidence` impedisce di riapplicarla al ricaricamento, anche dopo un annullamento o una correzione manuale. Viene incluso nei backup. Nel Diario puoi aprire il riepilogo delle deduzioni; ogni voce importata mostra il motivo in **Fonti e deduzioni**.

`Treasure Hunter` prova almeno 100 forzieri, ma solo quelli contenenti i dalmata sono identificabili. `Top Gun` non spunta le missioni Gummi; `Test Pilot` non identifica una singola missione dell’Excel. Restano da verificare conversazioni opzionali, ricompense da ritirare, coppe Solo/Time Trial e boss segreti.

## Snapshot del salvataggio analizzato

La schermata **Save** carica i file locali `KH1FM_Save_Analizzato.json` e `KH1FM_Report_Save.md`. Mostra separatamente i tre slot e propone lo slot 1: livello 53, Deep Jungle / Jungle: Tunnel, 9 ottobre 2026 alle 17:48. Premi **Confronta slot 1 con l’app** per esaminare valori attuali, valori del save e risultato. L’importazione richiede **Crea backup e importa slot 1**: viene prima scaricato e conservato un backup; **Annulla ultima operazione** ripristina i dati precedenti.

L’adattatore importa i 34 materiali (zeri inclusi), livelli delle magie, invocazioni, Keyblade, rapporti di Ansem, 33 gruppi di cuccioli, contatori Trinità/cartoline e 228 casse mappate. `null` rimane **Da verificare**. Le casse sono separate dai 268 tesori dell’Excel perché la mappatura è parziale; i contatori non identificano singole Trinità o cartoline. Fonte, data, confidenza e limiti restano consultabili accanto ai dati e nella schermata Save.

Le modifiche manuali sono conservate e i conflitti mostrano una scelta esplicita. Gli override successivi all’importazione appartengono allo slot attivo e non vengono trasferiti a un altro slot. Inventari diversi non vengono sommati. Lo storico della sintesi, le altre checklist, il piano e le raccolte restano conservati; il possesso degli oggetti non prova ricette già create. Gli snapshot e gli override sono inclusi nell’esportazione JSON e nel salvataggio locale.

## Avvio sul tuo PC

È consigliato Node.js 24 LTS (per lo sviluppo: almeno 22.12).

```bash
cd /home/federico/progetti/khapp
npm start
```

Apri **http://127.0.0.1:5173**. Lascia aperto il terminale durante l’uso; `Ctrl+C` ferma il server. La build consegnata è già pronta: per usarla non occorre installare pacchetti né avere una connessione Internet. I collegamenti alle guide esterne richiedono Internet; il PDF è locale.

### Collegamento sul desktop

`./scripts/desktop/install.sh` crea **Diario KH** nel menu applicazioni e sulla Scrivania. Il collegamento avvia il server (se non è già acceso) e apre l'app in una finestra di Chrome a sé, con un profilo dedicato. **⏻ Chiudi app**, accanto ad «Annulla ultima operazione», chiude la finestra e ferma il server; anche la X della finestra lo ferma. Un server avviato a mano con `npm start` o `npm run dev` resta acceso. Log del server: `$XDG_RUNTIME_DIR/kh-diario-server.log`.

Per modificare il codice:

```bash
npm install
npm run dev
```

Per rigenerare la versione pronta: `npm run build`. Il server di sviluppo e quello della build usano lo stesso indirizzo e la stessa porta: ferma uno prima di avviare l’altro. In questo ambiente le dipendenze sono state riutilizzate da un progetto locale perché l’accesso al registro npm era indisponibile.

## Inventario mentre giochi

- Apri **Inventario** per aggiornare le scorte. Le frecce diminuiscono/aumentano di 1; tenendole premute ripetono dopo 350 ms, ogni 90 ms. La ripetizione si ferma al rilascio, all’uscita dal pulsante, alla cancellazione del puntatore o alla perdita di focus della finestra.
- Clicca il numero per scriverne un altro. Sono ammessi soltanto interi tra 0 e 999999. Le frecce della tastiera funzionano con il campo a fuoco.
- Il campo vuoto significa **quantità sconosciuta**, mai zero. Le frecce e i pulsanti rapidi restano disabilitati finché non inserisci la scorta reale. Scrivi `0` per confermare l’assenza del materiale.
- +5 e +10 sono sempre accanto al campo. Tutti i calcoli si aggiornano subito e ogni operazione viene salvata prima di essere mostrata.
- L’ordine dei materiali è quello del PDF. I filtri mantengono la selezione delle righe finché non li premi di nuovo: raggiungere la sufficienza non sposta il pulsante sotto il mouse.
- Premi il nome di un materiale per vedere metodi, condizioni e fonti. Puoi sempre tornare all’inventario dalla navigazione.

## Ricette, piano e fonti

Stato iniziale: **End of the World, 2/33**. Soltanto Energy Bangle e Power Chain risultano sintetizzati; il loro numero storico di creazioni è sconosciuto. Nessun suggerimento del percorso è registrato come azione eseguita. Le tre scorte di cristalli non mostrate sono `null`. Le 30 fonti uniche partono da “Da verificare”.

**Segna già sintetizzato** corregge lo storico senza consumare materiali né aggiungere produzioni. **Sintetizza adesso** verifica gruppo e scorte confermate, consuma ingredienti e aggiunge Mythril/Dark Matter quando prodotti. Le ripetizioni non aumentano le ricette diverse. Il completamento è separato dal possesso dell’oggetto.

Il piano iniziale comprende 5 future Dark Matter e 10 futuri Orichalcum. Le quantità sono previsioni, fuori dall’inventario. Le produzioni vengono ricalcolate: inizialmente 3 Dark Matter e 1 Mythril. Ridurre le ricompense previste espande i costi delle produzioni necessarie. “Manca” include quanto devi ancora raccogliere; “Senza fonte” sottrae anche le ricompense future previste.

Il piano “Prime 15” include il percorso e le **3 Lucid Gem aggiuntive** del PDF. “Selezionate” include le ricette scelte ancora da completare; verifica gli sblocchi e segnala una sequenza incompleta quando servono altre ricette per aprire un gruppo. Non dichiara che la sola sufficienza aggregata garantisca un ordine eseguibile.

Nelle checklist, **Già raccolto** corregge lo storico senza cambiare scorte o previsione. **Raccolto adesso** aggiunge 1 e riduce la previsione di quel materiale di 1. Le modifiche manuali dell’inventario non identificano fonti e non modificano automaticamente la previsione: correggila nel Piano quando necessario. Contrassegnare “Non raccolto” indica una fonte ancora disponibile, non la pianifica da solo. Se salti una fonte prevista, riduci il numero di ricompense future nel Piano.

La Sessione offre raccolte +1/+5 e contatori separati per materiale, con aggiornamento atomico. Per Dark Matter/Orichalcum usa la checklist quando vuoi registrare anche la fonte e ridurre la previsione.

**Annulla ultima operazione** ripristina insieme inventario, completamenti, checklist, piano e contatori. La cronologia conserva fino a 100 operazioni, anche dopo la riapertura. Durante una pressione prolungata ogni incremento è un’operazione annullabile. La conferma “Già sintetizzata” non determina retroattivamente quante volte hai creato l’oggetto.

## Backup e recupero

1. Apri **Backup** nella navigazione.
2. Premi **Esporta backup JSON** e conserva il file scaricato.
3. Per ripristinarlo, scegli il file nella sezione Importa: vengono verificati schema, quantità, ricette, fonti, piano e cronologia.
4. Controlla l’anteprima, poi premi **Crea backup e sostituisci i dati**. Prima della sostituzione viene scaricato un JSON del profilo attuale e una copia viene conservata nel browser.
5. **Scarica il backup precedente** recupera la copia anteriore all’ultima importazione.

Usa `http://127.0.0.1:5173`. Il salvataggio condiviso si trova nella cartella `data/` del progetto; un JSON esportato è il backup portabile. Ricarica le altre schede dopo una modifica.

## Struttura

- `src/data.js`: 34 materiali, inventario iniziale, 33 ricette, 30 fonti, farming e regole condizionate strutturate. Modifica qui eventuali correzioni del dataset.
- `src/completion-data.json`: tutte le checklist, note e guide estratte dall’Excel, con riga e colonne originali.
- `scripts/import-checklist.py`: importatore riproducibile con la sola libreria standard Python. Esegui `python3 scripts/import-checklist.py` per rigenerare i dati e la copia scaricabile del file. Verifica i conteggi di ogni foglio e si interrompe se non corrispondono.
- `src/completion.js` e `src/Completion.jsx`: conteggi del 100%, checklist, collegamenti tra categorie e guide.
- `src/engine.js`: stato iniziale, sblocchi, calcoli, espansione delle dipendenze, simulazione, transazioni e validazione JSON.
- `src/storage.js`: persistenza nel browser, export e backup prima dell’importazione.
- `src/`: componenti delle viste, controlli di inventario e tema.
- `tests/engine.test.js`: casi di accettazione e regressione.
- `server.mjs`: server della build, solo sull’interfaccia locale.

La persistenza usa `localStorage` con schema 2, dataset di sintesi `kh1fm-2026-10-09` e checklist `kh1fm-checklist-1.03`. La chiave resta `kh1fm.profile.v1` per recuperare i profili esistenti. I salvataggi e i backup con schema 1 vengono migrati automaticamente, inclusa la cronologia: inventario, ricette e piano sono conservati. Un errore di scrittura non aggiorna lo stato visualizzato. Un profilo non leggibile viene conservato e le modifiche restano bloccate fino al ripristino da backup.

## Verifiche

```bash
npm test
npm run build
```

I 33 test verificano anche tutti i conteggi dell’Excel, il progresso totale, la sintesi condivisa, la migrazione dello schema 1 e il recupero dei nuovi backup. Sono verificati anche importazione, zeri, null, conflitti, separazione degli slot e annullamento. La verifica Playwright su desktop e telefono controlla anteprima senza modifiche, download del backup, importazione, riapertura e annullamento, senza errori JavaScript. Il documento `docs/verification.md` descrive le verifiche della precedente versione dedicata alla sintesi.


## Archivio condiviso nella cartella del progetto

Il server locale (anche con `npm run dev`) salva i progressi in `data/profile.json`, con scrittura atomica. Tutti i browser leggono lo stesso archivio all’apertura; ricarica una pagina già aperta per vedere le modifiche fatte altrove. Una modifica basata su dati vecchi viene rifiutata per evitare sovrascritture. Gli errori di scrittura non aggiornano i progressi mostrati.

Per trasferire il precedente salvataggio di Zen: apri Backup su Zen, premi **Esporta dati precedenti del browser**, quindi importa il JSON. L’archivio nuovo non sceglie automaticamente fra i vecchi profili dei browser. Le vecchie copie rimangono nel localStorage. Prima di ogni importazione il profilo condiviso viene conservato anche in `data/before-import.json`. La cartella `data/` è esclusa da Git; conserva un backup JSON o una copia della cartella.
