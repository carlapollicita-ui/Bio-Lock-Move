##Progetto Bio-Lock & Move

Bio-Lock & Move è un sistema biomedico e informatico progettato per combattere la sedentarietà. Il software blocca l'accesso al PC e richiede all'utente di eseguire un esercizio fisico (rotazioni della spalla) tracciato in tempo reale tramite i sensori dello smartphone per sbloccare la postazione. I dati cinematici ed energetici vengono poi salvati in un database relazionale locale.

---

## 📱 1. GUIDA ALLA CONFIGURAZIONE E COLLEGAMENTO SMARTPHONE

Per avviare il sistema e collegare i sensori del telefono a MATLAB, segui questi passi:

1. **Installazione:** Assicurarsi di avere installato l'applicazione gratuita **MATLAB Mobile** sul proprio smartphone.
2. **Accesso:** Accedi all'app sul telefono utilizzando le stesse credenziali del tuo account MathWorks.
3. **Connessione:** * Apri MATLAB sul Mac e assicurati di essere connesso a Internet.
   * Sullo smartphone, apri l'app, vai nella sezione **Sensors** (Sensori) e attiva lo switch su **On Accelerazione** per inviare i dati al cloud di MathWorks.
4. **Avvio del Programma:** * In MATLAB sul Mac, apri lo script principale `progetto_bio_lock.m`.
   * Premi il tasto **Run**.
5. **Inizializzazione:** La Command Window ti chiederà di inserire il tuo **Nome** e il tuo **Peso in kg** (fondamentale per personalizzare la sessione di allenamento). Inserisci i dati e premi **Invio**. Il sistema si collegherà al flusso dei sensori dello smartphone e si metterà in ascolto dei movimenti.

---

## 📊 2. GUIDA ALLA VISUALIZZAZIONE DEL DATABASE E DELLA JOIN

Il sistema si appoggia su un database relazionale SQLite (`biolock_database.db`) strutturato secondo una logica **Padre-Figlio (Uno a Molti)** tra la tabella `Utenti` e la tabella `StoricoSessioni`.

### Come visualizzare lo storico dei dati a fine sessione:
Al termine dell'esercizio, il programma salva i dati e stampa automaticamente nella Command Window di MATLAB la visualizzazione integrale del database, mostrando le due tabelle separate. Questo permette di verificare a schermo l'integrità dei dati salvati.

---

### 🛠️ Come visualizzare la JOIN in modalità Grafica (Database Explorer)

Se si desidera analizzare visivamente l'unione relazionale dei dati (JOIN), MATLAB offre uno strumento dedicato:

1. Nella barra dei menu in alto di MATLAB, seleziona la scheda **APPS**.
2. Cerca e avvia l'applicazione **Database Explorer**.
3. Nella barra degli strumenti dell'app, fare clic su **Connect** e seleziona **Open SQLite File**.
4. Seleziona il file del database presente nella cartella del progetto: `biolock_database.db`.
5. Nel pannello a sinistra (**Database Browser**):
   * **Seleziona (metti la spunta)** sulle tue due tabelle: **`Utenti`** e **`StoricoSessioni`**.
6. **La JOIN si genera automaticamente:** L'interfaccia mostrerà all'istante il tabellone unito nella scheda *Data Preview* e il grafico strutturale nella scheda *Join Diagram*.

*Nota sul numero di righe:* Se l'anteprima mostra inizialmente solo le prime 10 righe, clicca sul pulsante **Close Join** (la `X` grande a destra nella barra) per tornare alla barra strumenti principale. Nella casella **Preview Size** apparsa sulla destra, sostituisci `10` con `100` (o più) e premi **Invio** per caricare tutto lo storico completo.
