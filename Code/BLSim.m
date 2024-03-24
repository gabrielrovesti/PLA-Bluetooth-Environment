% Parametri del canale (inizializzati)
N = 100; % Numero di simulazioni
potenza = zeros(1, N); % Potenza del segnale (dB)
distanza = randi([1, 150]); % Generazione di distanza casuale tra 1 e 150 metri
autenticazione_chiave = 'key123'; % Chiave di autenticazione (valore iniziale)
autenticazione_lunghezza = length(autenticazione_chiave); % Lunghezza della chiave di autenticazione
dato_casuale = randi([0, 1], 1, 100); % Dato casuale di lunghezza 100 bit

% Inizializzazione dei vettori per salvare i risultati
SNR = zeros(1, N);
errori = zeros(1, N);

for i = 1:N
    % Generazione del segnale di autenticazione
    autenticazione_chiave = generate_random_key(autenticazione_lunghezza);

    % Generazione di un dato casuale di lunghezza 100 bit
    dato_casuale = randi([0, 1], 1, 100);

    % Generazione di potenza casuale tra -20 dBm e +20 dBm
    potenza(i) = randi([-20, 20]);

    % Generazione del segnale di autenticazione
    segnale_autenticazione = mix_signal(dato_casuale, autenticazione_chiave, potenza(i));

    % Ricezione del segnale dal canale (decodifica al ricevitore DA FARE POI)
    segnale_ricevuto = receive_signal(potenza(i), distanza);
    
    % Controllo degli errori - qua al posto di dato casuale, serve il
    % segnale di autenticazione
    errori(i) = check_errors(segnale_ricevuto, segnale_autenticazione); 
    
    %% Conteggio dei messaggi non legittimi accettati e dei messaggi legittimi rifiutati - DA FARE POI

    % Calcolo del rapporto segnale/rumore (SNR)
    % Calcolato come differenza tra la potenza del segnale e il path loss
    lambda = 0.125; % Lunghezza d'onda in metri (Bluetooth opera a circa 2.4 GHz)
    path_loss_dB = 20*log10(4*pi*distanza/lambda); % Calcolo del path loss in dB
    SNR_dB = potenza(i) - path_loss_dB; % SNR in dB
    SNR(i) = 10^(SNR_dB/10); % SNR in scala lineare
end

% Calcolo della media del numero di bit errati
media_bit_errati = mean(errori);

% Conteggio dei segnali con un numero di bit errati al di sopra e al di sotto della media
num_segnali_sopra_media = sum(errori > media_bit_errati);
num_segnali_sotto_media = sum(errori < media_bit_errati);

disp(['Numero medio di bit errati: ', num2str(media_bit_errati)]);
disp(['Numero di segnali con bit errati sopra la media: ', num2str(num_segnali_sopra_media)]);
disp(['Numero di segnali con bit errati sotto la media: ', num2str(num_segnali_sotto_media)]);

%% Qui prossimo calcolo del fading - dopo le simulazioni 

%% Plot

min_potenza = min(potenza);
max_potenza = max(potenza);

% Creazione delle tabelle per ogni variabile
tabella_potenza = table(min_potenza, max_potenza, 'VariableNames', {'Min Potenza (dB)', 'Max Potenza (dB)'});
tabella_distanza = table(distanza, 'VariableNames', {'Distanza (m)'});

% Unione delle tabelle
dati = [tabella_potenza, tabella_distanza];

% Visualizzazione della tabella
disp('Tabella Riassuntiva dei Dati:');
disp(dati);

% Grafico del rapporto segnale/rumore (SNR)
figure;
plot(1:N, SNR, 'r', 'LineWidth', 2);
title('Rapporto Segnale/Rumore (SNR)');
xlabel('Numero di Simulazioni');
ylabel('SNR (scala lineare)');
grid on
shg;

% Creazione del nome del file
nome_file = ['risultati_simulazione_' datestr(now,'yyyymmdd_HHMMSS') '.csv'];

% Scrittura delle intestazioni delle colonne nel file CSV
intestazioni = {'Potenza (dB)', 'Distanza (m)', 'SNR', 'Num. messaggi sopra media', 'Num. messaggi sotto media'};
writecell(intestazioni, nome_file, 'WriteMode', 'overwrite');

% Creazione della matrice dei risultati
risultati = [potenza, distanza, SNR, num_segnali_sopra_media, num_segnali_sotto_media];

% Aggiunta dei risultati al file CSV
writematrix(risultati, nome_file, 'WriteMode', 'append');
disp(['I risultati della simulazione sono stati salvati nel file: ' nome_file]);

function segnale_autenticazione = mix_signal(dato, chiave, potenza)
    % Verifica e adattamento delle lunghezze del dato casuale e della chiave di autenticazione
    if length(dato) > length(chiave)
        chiave = [chiave, zeros(1, length(dato) - length(chiave))];
    elseif length(dato) < length(chiave)
        chiave = chiave(1:length(dato));
    end
    
    % Inizializzazione del segnale di autenticazione
    segnale_autenticazione = zeros(1, length(dato));
    
    % Mixaggio del dato con la chiave di autenticazione utilizzando l'operatore XOR
    for i = 1:length(dato)
        % Converti caratteri in numeri binari utilizzando la funzione double
        dato_bin = double(dato(i));
        chiave_bin = double(chiave(i));
        % Applica bitxor ai numeri binari
        segnale_autenticazione(i) = bitxor(dato_bin, chiave_bin);
    end

    % Potenzia il segnale di autenticazione con la potenza fornita
    segnale_autenticazione = segnale_autenticazione * 10^(potenza/20);
end

function segnale_ricevuto = receive_signal(potenza, distanza)
    % Generazione di un segnale casuale
    segnale_inviato = randi([0, 1], 1, 100);
    
    % Calcolo del path loss
    lambda = 0.125; % Lunghezza d'onda in metri (Bluetooth opera a circa 2.4 GHz)
    path_loss_dB = 20*log10(4*pi*distanza/lambda); % Calcolo del path loss in dB
    
    % Calcolo del rapporto segnale/rumore (SNR) in dB
    SNR_dB = potenza - path_loss_dB; % SNR = Potenza del segnale - Path Loss
    
    % Conversione del SNR da dB a scala lineare
    SNR = 10^(SNR_dB/10); % SNR in scala lineare
    
    % Applicazione degli impairments RF (simulazione di effetti realistici)
    % Simuliamo un offset di frequenza casuale tra -1000 Hz e 1000 Hz
    offset_frequenza = randi([-1000, 1000]); % Offset di frequenza in Hz
    % Simuliamo un drift temporale casuale tra -5 ppm e 5 ppm
    drift_temporale = randi([-5, 5]); % Drift temporale in ppm
    % Simuliamo un offset DC casuale tra -5% e 5%
    offset_DC = randi([-5, 5])/100; % Offset DC come frazione del valore massimo
    
    % Applichiamo gli impairments RF direttamente al segnale inviato
    fs = 1e6; % Frequenza di campionamento (1 MHz)
    t = (0:length(segnale_inviato)-1)/fs; % Tempo
    % Applichiamo l'offset di frequenza
    segnale_con_offset = segnale_inviato .* exp(1i * 2*pi * offset_frequenza * t); 
    % Applichiamo il drift temporale
    drift = drift_temporale * 1e-6; % Drift temporale in ppm
    segnale_con_drift = interp1(t, segnale_con_offset, t + drift * max(t)); 
    % Applichiamo l'offset DC
    segnale_con_offset_DC = segnale_con_drift + offset_DC * max(abs(segnale_con_drift)); 
    
    % Aggiunta di rumore bianco gaussiano
    segnale_rumore = awgn(segnale_con_offset_DC, SNR); % Aggiunta di rumore bianco gaussiano con il SNR specificato
    
    % Ricezione del segnale
    segnale_ricevuto = segnale_rumore;
end

function errori = check_errors(segnale_ricevuto, segnale_autenticazione)
    % Verifica e adattamento delle lunghezze dei segnali
    min_length = min(length(segnale_ricevuto), length(segnale_autenticazione));
    segnale_ricevuto = segnale_ricevuto(1:min_length);
    segnale_autenticazione = segnale_autenticazione(1:min_length);

    % Conversione dei segnali in bit
    segnale_ricevuto_bit = logical(segnale_ricevuto > 0);
    segnale_autenticazione_bit = logical(segnale_autenticazione > 0);

    % Calcolo della distanza di Hamming (numero di bit diversi)
    errori = sum(segnale_ricevuto_bit ~= segnale_autenticazione_bit);
end

function chiave = generate_random_key(lunghezza)
    % Genera una chiave di autenticazione casuale di lunghezza specificata
    caratteri_validi = ['a':'z' 'A':'Z' '0':'9'];
    indice_carattere = randi([1, length(caratteri_validi)], 1, lunghezza);
    chiave = caratteri_validi(indice_carattere);
end


