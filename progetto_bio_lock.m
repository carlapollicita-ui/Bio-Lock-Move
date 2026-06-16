%% --- BIOLOCK & MOVE: DIGITAL WELLNESS ---
% Studentessa: Carla Pollicita
% Anno: 2025/2026
% Corso di Laurea: Ingegneria Biomedica — Università degli studi di Messina
% Corso: "Fondamenti di Informatica"
% Professore: Luca D'Agati

clear all; close all; clc;


%% 1. INIZIALIZZAZIONE SENSORI E RICHIESTA NOME UTENTE
fprintf('Inizializzazione sensori iPhone...\n');
try
    m = mobiledev; m.AccelerationSensorEnabled = 1;
catch
    error('Configura il telefono su "Streaming su: MATLAB" e clicca "START".');
end


% --- RICHIESTA DATI UTENTE ---
fprintf('\n==================================================\n');
fprintf('       BENVENUTO IN BIO-LOCK & MOVE               \n');
fprintf('==================================================\n\n');

nome_inserito = input('Inserisci il tuo nome utente per iniziare: ', 's');
nome_inserito = strtrim(nome_inserito); 

if isempty(nome_inserito)
    nome_inserito = 'Utente_Ospite'; 
end

% Richiesta del peso corporeo
peso_input = input('Inserisci il tuo peso in kg: ');
if isempty(peso_input) || isnan(peso_input) || peso_input <= 0
    peso_utente = 50.0; % Valore di default se non inserisce nulla di valido
else
    peso_utente = peso_input;
end


% --- CONNESSIONE AL DATABASE ---
fprintf('\nConnessione al database SQL relazionale...\n');
db_conn = sqlite('biolock_database.db', 'connect');

% Creazione preventiva delle due tabelle collegate relazionalmente (Padre e Figlio)
execute(db_conn, ['CREATE TABLE IF NOT EXISTS Utenti (' ...
                  'ID_Utente INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
                  'Nome TEXT, ' ...
                  'Peso_Kg REAL)']);

execute(db_conn, ['CREATE TABLE IF NOT EXISTS StoricoSessioni (' ...
                  'ID_Sessione INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
                  'ID_Utente INTEGER, ' ...
                  'Data_Ora TEXT, ' ...
                  'Giri_Spalla INTEGER, ' ...
                  'Calorie_Kcal REAL, ' ...
                  'Velocita_Rad_s REAL, ' ...
                  'FOREIGN KEY(ID_Utente) REFERENCES Utenti(ID_Utente))']);

% Verifichiamo se l'utente esiste già (Tabella Padre)
query_cerca = sprintf("SELECT ID_Utente FROM Utenti WHERE Nome = '%s';", nome_inserito);
risultato_ricerca = fetch(db_conn, query_cerca);

if isempty(risultato_ricerca)
    % Se non esiste lo inseriamo nella tabella Padre con il suo peso REALE inserito!
    execute(db_conn, sprintf("INSERT INTO Utenti (Nome, Peso_Kg) VALUES ('%s', %.1f);", nome_inserito, peso_utente));
    
    % Recuperiamo l'ID appena assegnato
    risultato_id = fetch(db_conn, sprintf("SELECT ID_Utente FROM Utenti WHERE Nome = '%s';", nome_inserito));
    id_utente_corrente = risultato_id{1, 1};
else
    % Se esiste già, prendiamo il suo ID vecchio e aggiorniamo il peso se è cambiato
    id_utente_corrente = risultato_ricerca{1, 1};
    execute(db_conn, sprintf("UPDATE Utenti SET Peso_Kg = %.1f WHERE ID_Utente = %d;", peso_utente, id_utente_corrente));
end


%% 2. CREAZIONE DEL WIDGET IN BACKGROUND
hWidget = figure('Name', 'Bio-Lock Timer', 'NumberTitle', 'off', 'MenuBar', 'none', ...
                 'ToolBar', 'none', 'Color', [0.94 0.94 0.94], 'Position', [1000, 50, 350, 180]); 
hAxWidget = axes('Parent', hWidget, 'Position', [0.1, 0.35, 0.8, 0.4]);
axis(hAxWidget, 'off'); axis(hAxWidget, 'image'); xlim(hAxWidget, [-5 105]); ylim(hAxWidget, [-5 55]);

hTextWidget = uicontrol('Parent', hWidget, 'Style', 'text', 'String', 'Monitoraggio...', ...
                        'FontSize', 12, 'FontName', 'Avenir Next', 'FontWeight', 'bold', ...
                        'Position', [10, 10, 330, 30], 'BackgroundColor', [0.94 0.94 0.94]);

rectangle('Parent', hAxWidget, 'Position', [0 0 100 50], 'Curvature', 0.1, 'LineWidth', 3);
rectangle('Parent', hAxWidget, 'Position', [100 15 4 20], 'Curvature', 0.2, 'FaceColor', [0.2 0.2 0.2]);
hEnergy = rectangle('Parent', hAxWidget, 'Position', [2 2 96 46], 'Curvature', 0.05, 'FaceColor', [0.2 0.7 0.2], 'EdgeColor', 'none');

tempo_lavoro = 10; 
for t = tempo_lavoro : -1 : 0
    if ~ishandle(hWidget), error('Widget chiuso.'); end
    carica = t / tempo_lavoro;
    set(hEnergy, 'Position', [2 2 max(0.1, 96*carica) 46]);
    set(hTextWidget, 'String', sprintf('Sessione attiva. Blocco tra: %d s', t));
    if carica <= 0.2, set(hEnergy, 'FaceColor', [0.8 0.2 0.2]); end
    drawnow; pause(1);
end
close(hWidget);


%% 3. CREAZIONE FINESTRA UNICA (Sfondo iniziale chiaro)
hFig = figure('Name', 'Bio-Lock & Move', 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Color', [0.94 0.94 0.94]); 
set(hFig, 'WindowState', 'maximized');

% L'albero situato perfettamente AL CENTRO dello schermo 
hAxAlbero = axes('Parent', hFig, 'Position', [0.30, 0.2, 0.4, 0.6]); 
axis(hAxAlbero, 'off'); axis(hAxAlbero, 'image'); axis(hAxAlbero, 'equal'); 
xlim(hAxAlbero, [-20 120]); ylim(hAxAlbero, [-10 70]);

% Grafico nascosto sulla destra
hAxPlot = axes('Parent', hFig, 'Position', [0.52, 0.2, 0.43, 0.55]); set(hAxPlot, 'Visible', 'off'); 

hText = uicontrol('Style', 'text', 'String', '', 'FontSize', 15, 'FontName', 'Avenir Next', 'FontWeight', 'bold', ...
                  'Position', [150, 140, 1200, 60], 'HorizontalAlignment', 'center');

% Dissolvenza fluida verso il nero
for grigio = 0.94 : -0.01 : 0.15
    if ~ishandle(hFig), return; end
    set(hFig, 'Color', [grigio grigio grigio]); set(hText, 'BackgroundColor', [grigio grigio grigio]);
    drawnow; pause(0.01); 
end
set(hText, 'ForegroundColor', [1 1 1], 'String', 'SISTEMA BLOCCATO! Fai 10 ROTAZIONI ampie del braccio.');

% Disegno del Germoglio su hAxAlbero
hold(hAxAlbero, 'on'); theta = linspace(0, pi, 50); t_cerchio = linspace(0, 2*pi, 30);
fill(hAxAlbero, 50 + 20*cos(theta), 2*sin(theta), [0.4 0.25 0.15], 'EdgeColor', 'none'); % Terra
hTronco = fill(hAxAlbero, [50 51 53 52], [0 8 15 0], [0.3 0.65 0.3], 'EdgeColor', 'none');
hFoglia1 = fill(hAxAlbero, 47+5*cos(t_cerchio), 12+3*sin(t_cerchio), [0.4 0.8 0.4], 'EdgeColor', 'none');
hFoglia2 = fill(hAxAlbero, 53+1*cos(t_cerchio), 14+1*sin(t_cerchio), [0.4 0.8 0.4], 'EdgeColor', 'none'); set(hFoglia2, 'Visible', 'off');
hChioma = fill(hAxAlbero, 50+15*cos(t_cerchio), 35+15*sin(t_cerchio), [0.2 0.55 0.2], 'EdgeColor', 'none'); set(hChioma, 'Visible', 'off');

% Fiori inizialmente invisibili
hFiore1 = fill(hAxAlbero, 40+3*cos(t_cerchio), 30+3*sin(t_cerchio), [1 0.4 0.6], 'EdgeColor', 'none'); set(hFiore1, 'Visible', 'off');
hFiore2 = fill(hAxAlbero, 60+3*cos(t_cerchio), 32+3*sin(t_cerchio), [1 0.4 0.6], 'EdgeColor', 'none'); set(hFiore2, 'Visible', 'off');
hFiore3 = fill(hAxAlbero, 52+3*cos(t_cerchio), 35+3*sin(t_cerchio), [1 0.5 0.5], 'EdgeColor', 'none'); set(hFiore3, 'Visible', 'off');
drawnow;


%% 4. ALGORITMO RILEVAMENTO ROTAZIONI, CALORIE E VELOCITÀ (TARATURA BILANCIATA)
discardlogs(m); rotazioni_necessarie = 10; rotazioni = 0; ultima_rotazione = 0;

while rotazioni < rotazioni_necessarie
    if ~ishandle(hFig), error('Finestra chiusa.'); end
    [log_a, ~] = accellog(m);
    
    if ~isempty(log_a)
        % Torniamo al segnale originale reattivo
        acc_rotazione = sqrt(log_a(:,2).^2 + log_a(:,3).^2) - 9.81;
        
        % SOGLIE BILANCIATE: Via di mezzo perfetta
        soglia = 2.5;        
        distanza_minima = 18;  
        posizioni = [];
        
        % Controllo dei picchi
        for i = 2 : length(acc_rotazione)-1
            if acc_rotazione(i) > soglia && acc_rotazione(i) > acc_rotazione(i-1) && acc_rotazione(i) > acc_rotazione(i+1)
                if isempty(posizioni) || (i - posizioni(end)) > distanza_minima
                    posizioni = [posizioni; i];
                end
            end
        end
        rotazioni = length(posizioni);
        rotazioni_totali = rotazioni; % Allineamento variabile di backup
        
        % Calcolo velocità e calorie
        raggio_braccio = 0.6; 
        omega_media = mean(sqrt(abs(acc_rotazione(posizioni))) / raggio_braccio);
        if isnan(omega_media), omega_media = 0; end
        calorie_stimate = rotazioni * 0.15;
        
        set(hText, 'String', sprintf('Spalla: %d/%d giri | Velocità: %.1f rad/s | Energia: %.2f kcal', ...
            rotazioni, rotazioni_necessarie, omega_media, calorie_stimate));
        
        if rotazioni > ultima_rotazione, beep; ultima_rotazione = rotazioni; end
        
        % Crescita dinamica dell'albero
        if rotazioni >= 3 && rotazioni < 6
            set(hTronco, 'XData', [50 52 55 52], 'YData', [0 15 25 0]);
            set(hFoglia1, 'XData', 45+7*cos(t_cerchio), 'YData', 18+4*sin(t_cerchio)); set(hFoglia2, 'Visible', 'on');
        elseif rotazioni >= 6
            set(hTronco, 'XData', [48 52 56 54], 'YData', [0 25 40 0], 'FaceColor', [0.5 0.35 0.2]); 
            set(hChioma, 'Visible', 'on'); set(hFoglia1, 'Visible', 'off'); set(hFoglia2, 'Visible', 'off');
        end
        drawnow;
    end
    pause(0.4);
end


%% 5. TRANSIZIONE: SBOCCIANO I FIORI, Esercizio Valido
set(hText, 'String', 'ESERCIZIO CONVALIDATO! ALBERO FIORITO!', 'ForegroundColor', [0.2 0.8 0.2]);
set(hFiore1, 'Visible', 'on'); set(hFiore2, 'Visible', 'on'); set(hFiore3, 'Visible', 'on'); drawnow;
pause(1);

% Lo sfondo torna chiaro
for grigio = 0.15 : 0.01 : 0.94
    if ~ishandle(hFig), return; end
    set(hFig, 'Color', [grigio grigio grigio]); set(hText, 'BackgroundColor', [grigio grigio grigio]);
    drawnow; pause(0.01); 
end

% Spostamento dinamico fluido dell'asse dell'albero verso sinistra
for x_pos = 0.30 : -0.01 : 0.05
    if ~ishandle(hFig), return; end
    set(hAxAlbero, 'Position', [x_pos, 0.2, 0.4, 0.6]);
    drawnow; pause(0.005);
end

set(hText, 'ForegroundColor', [0.2 0.2 0.2], 'String', sprintf('Report Sessione - Energia Spesa: %.2f kcal', calorie_stimate));

% Attivazione del grafico sul lato destro
plot(hAxPlot, acc_rotazione, 'LineWidth', 1.5, 'Color', [0.1 0.6 0.6]); hold(hAxPlot, 'on');
line(hAxPlot, [1 length(acc_rotazione)], [soglia soglia], 'Color', [0.8 0.2 0.2], 'LineStyle', '--', 'LineWidth', 1.5);

if ~isempty(posizioni)
    plot(hAxPlot, posizioni, acc_rotazione(posizioni), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', [1 0.2 0.2]);
    legend(hAxPlot, 'Segnale Accelerazione YZ', 'Soglia di Convalida', 'Rotazioni Convalidate', 'Location', 'northeast');
end

title(hAxPlot, 'Analisi dei Picchi Cinematici della Spalla', 'FontSize', 12, 'FontName', 'Avenir Next', 'FontWeight', 'bold');
xlabel(hAxPlot, 'Campioni Temporali (n)'); ylabel(hAxPlot, 'Forza Accelerativa Dinamica (m/s^2)'); grid(hAxPlot, 'on');
set(hAxPlot, 'Visible', 'on'); drawnow;


%% 6. ARCHIVIAZIONE DATI IN DATABASE RELAZIONALE
% Cattura del timestamp corrente
data_ora_attuale = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));

% Generazione ed esecuzione della query di inserimento sessione legata all'ID Utente
query_insert = sprintf(['INSERT INTO StoricoSessioni ' ...
    '(ID_Utente, Data_Ora, Giri_Spalla, Calorie_Kcal, Velocita_Rad_s) ' ...
    'VALUES (%d, "%s", %d, %.2f, %.2f)'], ...
    id_utente_corrente, data_ora_attuale, rotazioni, calorie_stimate, omega_media);

execute(db_conn, query_insert);

% Visualizzazione del tabellone dello storico riassuntivo 
fprintf('\n==================================================\n');
fprintf('     STORICO AGGIORNATO PER L''UTENTE: %s\n', upper(nome_inserito));
fprintf('==================================================\n');

% VISUALIZZAZIONE INTEGRALE DEL DATABASE CON TUTTE LE COLONNE 
fprintf('\n==================================================\n');
fprintf('     VISUALIZZAZIONE COMPLETA DEL DATABASE        \n');
fprintf('==================================================\n');

try
    % 1. Estrazione e stampa della Tabella PADRE (Utenti)
    fprintf('\n>>> TABELLA PADRE: "Utenti" <<<\n');
    tutto_utenti = fetch(db_conn, 'SELECT * FROM Utenti;');
    if ~isempty(tutto_utenti)
        % Trasforma in tabella usando i nomi automatici delle colonne di MATLAB
                % Creazione tabella MATLAB e sovrascrittura metadati per evitare doppioni
        T_utenti = array2table(tutto_utenti);
        T_utenti.Properties.VariableNames = {'ID_Utente', 'Nome_Utente', 'Lunghezza_Braccio_cm'};
        disp(T_utenti);

    else
        fprintf('Tabella Utenti vuota.\n');
    end
    
    fprintf('--------------------------------------------------\n');
    
    % 2. Estrazione e stampa della Tabella FIGLIO (StoricoSessioni)
    fprintf('\n>>> TABELLA FIGLIO: "StoricoSessioni" <<<\n');
    tutto_sessioni = fetch(db_conn, 'SELECT * FROM StoricoSessioni;');
    if ~isempty(tutto_sessioni)
        % Trasforma in tabella usando i nomi automatici delle colonne di MATLAB
                % Creazione tabella MATLAB e sovrascrittura metadati per evitare doppioni
        T_sessioni = array2table(tutto_sessioni);
        T_sessioni.Properties.VariableNames = {'ID_Sessione', 'ID_Utente', 'Data_Ora', 'Giri_Spalla', 'Calorie_Kcal', 'Velocita_Rad_s'};
        disp(T_sessioni);


    else
        fprintf('Tabella StoricoSessioni vuota.\n');
    end

catch
    % Se i dati sono in formato testo/misto, stampa diretta
    fprintf('\n>>> DATI UTENTI <<<\n');
    disp(tutto_utenti);
    fprintf('--------------------------------------------------\n');
    fprintf('\n>>> DATI STORICO SESSIONI <<<\n');
    disp(tutto_sessioni);
end
fprintf('==================================================\n\n');

% Chiusura connessione e disattivazione sensori
close(db_conn);
m.AccelerationSensorEnabled = 0; 
msgbox('Esercizio completato. Il computer è sbloccato!', 'Bio-Lock & Move Concluso');
