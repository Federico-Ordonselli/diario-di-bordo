# Diario KH — Flutter

L’overview completa e aggiornata è in [OVERVIEW.md](OVERVIEW.md).

Diario personale offline per Kingdom Hearts 1 Final Mix. Il progetto principale è ora Flutter/Dart: interfaccia Material 3 scura, accenti oro, navigazione laterale su desktop e menu su telefono. I controlli sono in italiano; il contenuto originale delle guide rimane in inglese.

Sono stati trasferiti tutti i dataset e le sezioni dell’app precedente: **794 obiettivi in 15 categorie**, 34 materiali, 33 ricette, 30 fonti uniche, guide, farming, piano, sessione, snapshot dei save, preparazione e backup. La vecchia implementazione React è conservata in `legacy/web/`, per recupero e confronto. Flutter non usa React, Node, un browser o un server locale a runtime.

## Avvio Linux

Serve **Flutter stable ≥ 3.35, Dart ≥ 3.9**, con gli strumenti desktop Linux (Clang, CMake, Ninja, GTK 3 e pkg-config). Installazione: [documentazione Flutter](https://docs.flutter.dev/install).

```bash
cd /home/federico/progetti/khapp
./scripts/flutter/bootstrap.sh
./scripts/flutter/check.sh
./scripts/desktop/launch.sh
```

`bootstrap.sh` genera i runner mancanti per Android, iOS, macOS e Windows dai template dell’SDK installato, senza sovrascrivere i file Dart o il runner Linux già incluso. Configura i permessi macOS per i file selezionati e il nome dell’app. Eseguire il bootstrap richiede l’SDK e l’accesso iniziale alle dipendenze pub. I runner Android, iOS, macOS e Windows sono stati generati con Flutter 3.47.7 e sono ora presenti nel progetto.

`check.sh` formatta il Dart, esegue analisi e test e compila il bundle Linux. Il launcher apre il binario nativo e imposta `KH_DATA_DIR` sulla cartella `data/` già presente nel progetto. Il profilo esistente viene letto in quel percorso: le scorte e i progressi personali non sono distribuiti come asset. Per aggiornare il collegamento desktop, dopo la compilazione:

```bash
./scripts/desktop/install.sh
```

Per lo sviluppo, usando lo stesso profilo:

```bash
KH_DATA_DIR="$PWD/data" flutter run -d linux
```

Anche avviata direttamente senza `KH_DATA_DIR`, la build nel progetto ritrova automaticamente `data/` a partire dal percorso del binario o dalla cartella di lavoro. Un bundle autonomo fuori dal progetto usa la cartella di supporto fornita da `path_provider`. `KH_DATA_DIR` mantiene la priorità; il percorso effettivo è visibile in Backup. Per un profilo di prova usa una cartella separata:

```bash
KH_DATA_DIR=/tmp/kh-diario-prova flutter run -d linux
```

## Android, iOS e altri desktop

Il codice Dart è condiviso tra le piattaforme native. Dopo il bootstrap:

```bash
flutter devices
flutter run -d <id-dispositivo>
flutter build apk --release
```

iOS e macOS richiedono macOS/Xcode e la configurazione di firma; Windows richiede Windows e gli strumenti Visual Studio. Le build di queste piattaforme non sono state eseguite in questo ambiente. Per distribuire Linux, conserva **tutto** `build/linux/x64/release/bundle/`, non soltanto il binario. Il web non è un target di questa conversione: la persistenza è nativa su file.

## Funzioni e regole conservate

- **Diario / Checklist:** tutte le 794 voci, ricerca in nomi, requisiti, note e ricompense; filtri per categoria, stato, mondo e gruppo; caricamento di 40 voci alla volta. Dettagli espandibili con colonne, commenti, riga Excel, collegamenti e provenienza. Lo stato sconosciuto resta distinto da quello incompleto.
- **Guide:** sezioni dell’Excel, fonti dei materiali, consigli e boss segreti. Excel, PDF e report sono inclusi negli asset ed esportabili senza Internet. I link esterni richiedono una connessione.
- **Dashboard / Inventario:** scorte confermate o sconosciute, quantità da 0 a 999999, incrementi ripetuti, +5/+10, fonti di farming e deficit. I filtri dell’inventario mantengono le righe selezionate mentre aggiorni le scorte.
- **Ricette:** gruppi I–VI con gli stessi requisiti di sblocco. “Segna già sintetizzato” corregge lo storico; “Sintetizza adesso” verifica gruppo e materiali, consuma gli ingredienti e registra la produzione. Ricette e checklist condividono `everCrafted`.
- **Piano:** tutta la sintesi, prime 15 oppure ricette selezionate. Espansione Dark Matter → Mythril → ingredienti, ricompense future separate dall’inventario, deficit incerti e simulazione dell’ordine eseguibile. Le tre Lucid Gem aggiuntive del percorso rimangono incluse.
- **Farming / Sessione:** metodi, condizioni, reset, probabilità, regole speciali, Lucky Strike e contatori di sessione. Raccolte +1/+5 aggiornano inventario e sessione insieme.
- **Collezionabili:** raccolta retroattiva distinta da raccolta attuale; solo quella attuale modifica inventario e ricompense future.
- **Preparazione:** edizione, livello, MP, Lucky Strike, Munny e disponibilità delle abilità. I campi si confermano con Invio o quando perdono il focus.
- **Save:** apertura degli snapshot JSON analizzati, confronto di un singolo slot, scelta per ogni conflitto, backup prima dell’importazione. Conserva osservazioni, fonte, hash, confidenza, slot, date e override. Contatori di Trinità/cartoline e casse mappate sono indipendenti dalle checklist Excel. Lo storico della sintesi non viene dedotto dagli oggetti posseduti.
- **Backup:** export/import JSON compatibili con schema 1 e 2 della vecchia app. Anteprima e copia precedente su disco. Ripristinare un backup sostituisce anche la cronologia con quella del backup; per tornare al profilo precedente importa la copia precedente. L’importazione di uno slot, invece, è una transazione annullabile.

I progressi degli screenshot sono importati una sola volta anche sui nuovi profili; i marcatori già presenti e quelli conservati dopo un annullamento impediscono la riapplicazione.

## Persistenza e migrazione

Il formato del profilo resta schema 2, dataset `kh1fm-2026-10-09` e checklist `kh1fm-checklist-1.03`. Lo schema 1 viene migrato all’apertura e all’importazione, inclusa la cronologia. Le operazioni conservano fino a 100 stati precedenti.

Le scritture usano un file temporaneo con flush e rename, un lock del file e un confronto con la revisione letta: una finestra con un profilo vecchio deve ricaricare prima di scrivere. Un errore di persistenza non cambia lo stato visualizzato. Un profilo illeggibile viene conservato e blocca le modifiche fino al ripristino da backup. Prima di un’importazione, il file precedente viene salvato atomicamente in `before-import.json`.

La versione React archiviata non partecipa al lock nativo: chiudila prima di usare Flutter sul medesimo profilo. I dati personali in `data/` restano esclusi da Git.

Su Android/iOS l’esportazione usa il pannello di condivisione del sistema; su desktop usa una finestra di salvataggio. I backup vengono creati prima dell’importazione; annullare l’esportazione interrompe la sostituzione. Un nuovo telefono parte con un profilo iniziale: trasferisci i progressi usando il backup JSON.

## Struttura

```text
lib/main.dart                    caricamento asset e avvio
lib/domain/catalog.dart          cataloghi e conteggi
lib/domain/engine.dart           calcoli e transazioni
lib/domain/save_adapter.dart     snapshot, conflitti e importazione
lib/domain/validation.dart       validazione e migrazione dei backup
lib/storage/                     archivio nativo e controller
lib/ui/                          navigazione, pagine e controlli
assets/datasets/                 dataset completi e stato iniziale
assets/documents/                Excel, PDF, report
linux/                          runner nativo Linux
scripts/flutter/                 bootstrap e verifiche
scripts/desktop/                 avvio e collegamento nativo
legacy/web/                      implementazione React precedente
```

`python3 scripts/import-checklist.py` rigenera le checklist dall’Excel originale con la sola libreria standard Python. `node scripts/flutter/verify-data.mjs` confronta dataset, documenti e compatibilità del profilo personale senza modificarlo. `node scripts/export-flutter-data.mjs` esporta i dati e le fixture di confronto dal motore originale; è uno strumento di manutenzione, non una dipendenza dell’app.

## Stato delle verifiche

Flutter **3.47.7 stable** e Dart **3.13.5** sono installati in `/home/federico/.local/share/flutter`, con comandi disponibili in Bash, Zsh e Fish. La toolchain Linux risulta pronta secondo `flutter doctor`.

Verifiche completate: `flutter analyze` senza problemi, **31 test Flutter superati**, build Linux release riuscita e avvio del binario nativo verificato sia con un profilo temporaneo sia con l’archivio reale. L’avvio diretto da `/tmp` senza `KH_DATA_DIR` ha letto 456/794 obiettivi, 12/33 sintesi e livello 54; il checksum del profilo è rimasto invariato. Sono passati anche i 34 test del motore originale e i confronti dei dataset/documenti. Il profilo personale è stato validato in Dart senza modificarlo: stato e piano coincidono con il motore originale.

Android SDK non installato; build APK, iOS, macOS e Windows non eseguite. L’importazione/esportazione tramite dialoghi nativi e condivisione mobile richiede ancora una verifica interattiva sui rispettivi sistemi.

I test Flutter includono:

- parità di piano e simulazione in sei scenari con risultati del motore JavaScript;
- parità delle transazioni, dei tre slot normalizzati, dell’anteprima e dell’importazione;
- quantità sconosciute, sblocchi, sessioni, migrazione, annullamento e cronologia;
- conflitti manuali, separazione degli slot e validazione dei contatori;
- persistenza, revisione e backup su un archivio temporaneo;
- scelta dell’archivio per avvio diretto, sviluppo, override esplicito e bundle autonomo;
- navigazione in tutte le 13 sezioni su desktop/telefono e controlli a pressione prolungata.

Per ripetere le verifiche esegui `./scripts/flutter/check.sh`. Il dettaglio della migrazione si trova in `docs/flutter-migration.md`.
