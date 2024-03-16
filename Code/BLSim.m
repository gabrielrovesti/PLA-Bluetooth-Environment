% Parametri del canale (inizializzati)
potenza = 10; % Potenza del segnale (dB)
distanza = 100; % Distanza del canale (metri)
autenticazione_chiave = 'key123'; % Chiave di autenticazione
autenticazione_lunghezza = length(autenticazione_chiave); % Lunghezza della chiave di autenticazione
dato_casuale = randi([0, 1], 1, 100); % Dato casuale di lunghezza 100 bit
N = 100; % Numero di simulazioni

% Inizializzazione dei vettori per salvare i risultati
num_messaggi_non_legittimi_accettati = zeros(1, N);
num_messaggi_legittimi_rifiutati = zeros(1, N);
distanza_hamming = zeros(1, N);
fading = zeros(1, N);
SNR = zeros(1, N);
errori = zeros(1, N);

for i = 1:N
    % Generazione del segnale di autenticazione
    autenticazione_chiave = generate_random_key(autenticazione_lunghezza);

    % Generazione di un dato casuale di lunghezza 100 bit
    dato_casuale = randi([0, 1], 1, 100);

    % Generazione di distanza casuale tra 1 e 150 metri
    distanza = randi([1, 150]);

    % Generazione di potenza casuale tra -20 dBm e +20 dBm
    potenza = randi([-20, 20]);

    % Generazione del segnale di autenticazione
    segnale_autenticazione = mix_signal(dato_casuale, autenticazione_chiave);

    % Calcolo della distanza di Hamming tra segnale inviato e ricevuto
    distanza_hamming(i) = calculate_hamming_distance(dato_casuale, segnale_autenticazione);

    % Calcolo della percentuale di bit errati
    percentuale = (sum(errori(1:i)) / (length(dato_casuale) * i)) * 100; % Percentuale di bit errati sul totale dei bit inviati

    % Calcolo della threshold
    threshold = calculate_threshold(distanza_hamming(i), percentuale);

    % Ricezione del segnale dal canale
    segnale_ricevuto = receive_signal(potenza, distanza);

    % Decodifica del segnale sulla base della distanza
    if distanza_hamming(i) <= threshold
        messaggio_ricevuto = decode_signal(segnale_ricevuto);
    else
        messaggio_ricevuto = 'Messaggio non legittimo';
    end

    % Calcolo del fading del segnale
    fading(i) = calculate_fading(segnale_ricevuto);

    % Controllo degli errori
    errori(i) = check_errors(messaggio_ricevuto, dato_casuale);
    
    % Conteggio dei messaggi non legittimi accettati e dei messaggi legittimi rifiutati
    if strcmp(messaggio_ricevuto, 'Messaggio non legittimo')
        num_messaggi_non_legittimi_accettati(i) = 1;
    else
        num_messaggi_legittimi_rifiutati(i) = 1;
    end

    % Calcolo del rapporto segnale/rumore (SNR)
    % Calcolato come differenza tra la potenza del segnale e il path loss
    lambda = 0.125; % Lunghezza d'onda in metri (Bluetooth opera a circa 2.4 GHz)
    path_loss_dB = 20*log10(4*pi*distanza/lambda); % Calcolo del path loss in dB
    SNR_dB = potenza - path_loss_dB; % SNR in dB
    SNR(i) = 10^(SNR_dB/10); % SNR in scala lineare
end


% Plot dei risultati
figure;

% Parametri energetici e di distanza del canale
subplot(2, 3, 1);
histogram(potenza*ones(1, N), 'FaceColor', 'blue');
xlabel('Potenza del segnale (dB)');
ylabel('Numero di simulazioni');
title('Distribuzione della potenza del segnale');
xlim([min(potenza)*1.1, max(potenza)*1.1]); % Incremento del range dell'asse x del 10%


subplot(2, 3, 2);
histogram(distanza*ones(1, N), 'FaceColor', 'green');
xlabel('Distanza del canale (metri)');
ylabel('Numero di simulazioni');
title('Distribuzione della distanza del canale');

% Distanza di Hamming
subplot(2, 3, 3);
histogram(distanza_hamming, 'FaceColor', 'red');
xlabel('Distanza di Hamming');
ylabel('Numero di simulazioni');
title('Distribuzione della distanza di Hamming');

% Fading del segnale
subplot(2, 3, 4);
histogram(fading, 'FaceColor', 'yellow');
xlabel('Fading del segnale');
ylabel('Numero di simulazioni campionate');
title('Distribuzione del fading del segnale');

% Rapporto segnale/rumore (SNR)
subplot(2, 3, 5);
histogram(SNR, 'FaceColor', 'magenta');
xlabel('SNR (dB)');
ylabel('Numero di simulazioni');
title('Distribuzione del rapporto segnale/rumore');

% Errori
subplot(2, 3, 6);
bar([sum(errori), sum(num_messaggi_non_legittimi_accettati), sum(num_messaggi_legittimi_rifiutati)], 'FaceColor', 'cyan');
xticks(1:3);
xticklabels({'Errori totali', 'Messaggi non legittimi accettati', 'Messaggi legittimi rifiutati'});
ylabel('Numero bit errati');
title('Statistiche degli errori');

function segnale_autenticazione = mix_signal(dato, chiave)
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
end


function distanza_hamming = calculate_hamming_distance(segnale_inviato, segnale_ricevuto)
    % Assicuriamoci che i segnali abbiano la stessa lunghezza
    if length(segnale_inviato) ~= length(segnale_ricevuto)
        error('I segnali devono avere la stessa lunghezza.');
    end
    
    % Calcolo della distanza di Hamming
    distanza_hamming = sum(segnale_inviato ~= segnale_ricevuto);
end

function threshold = calculate_threshold(distanza_hamming, percentuale)
    % Calcolo della soglia come percentuale della massima distanza di Hamming possibile
    threshold = percentuale * distanza_hamming / 100;
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


function fading = calculate_fading(segnale_ricevuto)
    % Calcola il fading del segnale ricevuto
    
    % Definisci il numero di campioni per la finestra temporale
    num_campioni_finestra = 100;
    
    % Calcola il numero totale di finestre temporali
    num_finestre = floor(length(segnale_ricevuto) / num_campioni_finestra);
    
    % Inizializza un vettore per memorizzare l'energia del segnale in ogni finestra temporale
    energia_finestre = zeros(1, num_finestre);
    
    % Calcola l'energia del segnale in ogni finestra temporale
    for i = 1:num_finestre
        indice_inizio = (i - 1) * num_campioni_finestra + 1;
        indice_fine = indice_inizio + num_campioni_finestra - 1;
        finestra = segnale_ricevuto(indice_inizio:indice_fine);
        energia_finestre(i) = sum(abs(finestra).^2);
    end
    
    % Calcola il fading come la variazione percentuale dell'energia media nel tempo
    energia_media = mean(energia_finestre);
    fading = 10 * log10(energia_media / mean(abs(segnale_ricevuto).^2));
end

function errori = check_errors(messaggio_ricevuto, dato_casuale)
    % Verifica e adattamento delle lunghezze dei messaggi
    if length(messaggio_ricevuto) ~= length(dato_casuale)
        min_length = min(length(messaggio_ricevuto), length(dato_casuale));
        messaggio_ricevuto = messaggio_ricevuto(1:min_length);
        dato_casuale = dato_casuale(1:min_length);
    end
    
    % Calcolo degli errori contando i bit diversi tra i due messaggi
    errori = sum(messaggio_ricevuto ~= dato_casuale);
end

function chiave = generate_random_key(lunghezza)
    % Genera una chiave di autenticazione casuale di lunghezza specificata
    caratteri_validi = ['a':'z' 'A':'Z' '0':'9'];
    indice_carattere = randi([1, length(caratteri_validi)], 1, lunghezza);
    chiave = caratteri_validi(indice_carattere);
end


