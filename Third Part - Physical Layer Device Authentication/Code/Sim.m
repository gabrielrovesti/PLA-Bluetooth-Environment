clc;
clear all; close all;

% Creazione di un oggetto RSA
rsa = RSA();

% Numero di trasmissioni da simulare
N = 100; 

% Generazione potenza di trasmissione e di chiave (in milliwatt)
potenza_dato = randi([-20, 20], 1, N); % Potenza di trasmissione

% Generazione dati e chiavi casuali per tutte le trasmissioni a 100 bit
dato = randi([0,1], 1, 100); 
% dato = randi([0,1], 100); % Questo per rendere segnale diverso per 100 distanze

% Criptare il messaggio dato utilizzando la chiave pubblica
dato_crittato = rsa.encrypt(dato);

% Invio del segnale corretto con certa potenza mischiato con chiave RSA
segnale_inviato = dato_crittato .* 10.^(potenza_dato/20);

% Vettori per successivi ragionamenti
distanza = [];
segnale_ricevuto = [];
segnale_filtrato = [];
messaggio_decodificato = [];
num_bit_errati = 0;

messaggio_decrittato = [];
false_alarms = [];
missed_detections = [];

% Mandare il segnale e ricalcolo segnale al ricevitore (decodifica)
% Threshold iniziali e verifichiamo quanto il segnale con rumori disti 

for i = 1:30  % Poiché 150/5 = 30
    
    % Calcola la nuova distanza
    if i == 1
        distanza(i) = 5;
    else
        distanza(i) = distanza(i-1) + 5;
    end
    
    % Effetto canale su segnale ricevuto corretto (disturbato)
    segnale_ricevuto = simulazione_canale(segnale_inviato, distanza(i));

    % Filtro del rumore e normalizzazione per togliere rumore condiviso
    % e prendere il segnale integro (bassa frequenza)
    % rispetto a rumore e interferenza (alta frequenza)

    ordine_filtro = 10; % Come separiamo le frequenze
    frequenza_norm = 0.3; % Normalizzazione = tagliare il segnale da una certa soglia
    filtro_low_band = fir1(ordine_filtro, frequenza_norm); % Taglio del segnale finito (FIR) per filtrarlo su coefficienti

    segnale_filtrato = filter(filtro_low_band, 1, segnale_ricevuto);

    % Soglie dinamiche su segnale ricevuto (filtrato)
    p_min_fs = min(segnale_filtrato);
    p_max_fs = max(segnale_filtrato);

    % Decodifica bit per bit del segnale ricevuto con disturbo (per BER)
    for j = 1:length(segnale_filtrato)

        % Decodifica in forma segnale messaggio
        if segnale_filtrato(j) > 0
            if segnale_filtrato > p_max_fs
                messaggio_decodificato(j) = 1;
            else
                messaggio_decodificato(j) = 0;
            end
        else
            if segnale_filtrato(j) < p_min_fs
                messaggio_decodificato(j) = 0;
            else
                messaggio_decodificato(j) = 1;
            end
        end

        % Calcolo del numero di bit errati sul dato
        % Distanza di Hamming
        if messaggio_decodificato(j) ~= dato_crittato(j)
            num_bit_errati = num_bit_errati + 1;
        end
    end

    % Calcolo del BER per messaggio e chiave
    BER(i) = num_bit_errati / length(messaggio_decodificato);
end

% Decriptare il messaggio giusto

% Messaggi autentici e non autentici = non ha senso "saperlo prima",
% perché va capito dinamicamente (o con thresholds o con qualcos'altro)

% messaggio_decrittato = rsa.decrypt(segnale_ricevuto);

% False alarm = Messaggi giusti interpretati come sbagliati (falsi
% positivi) sul numero di messaggi totali inviati. Questo è una
% percentuale

% % Missed detection = Messaggi sbagliati interpretati come giusti
% % (rilevazioni scorrette - misdetections) sul numero di messaggi totali inviati. 
% Questo è una percentuale

% Flusso di bit trasmesso nel tempo (convertito in vettore)
tempo = 1:length(segnale_inviato);

% Plot del segnale originale e del segnale ricevuto
figure;

% Plot del segnale trasmesso
subplot(2, 2, 1);
plot(tempo, segnale_inviato, 'LineWidth', 2);
title('Segnale Trasmesso');
xlabel('Tempo');
ylabel('Ampiezza (dB)');
grid on;

% Plot del segnale ricevuto
subplot(2, 2, 2);
plot(tempo, segnale_ricevuto, 'LineWidth', 2);
title('Segnale Ricevuto');
xlabel('Tempo');
ylabel('Ampiezza (dB)');
grid on;

% Plot del segnale filtrato
subplot(2, 2, 3);
plot(tempo, segnale_filtrato, 'LineWidth', 2);
title('Segnale Filtrato');
xlabel('Tempo');
ylabel('Ampiezza (dB)');
grid on;

% Plot del BER per segnale dato
subplot(2, 2, 4);
plot(distanza, BER, '-o', 'LineWidth', 2);
title('Bit Error Rate (BER) per segnale dato + chiave');
xlabel('Distanza (m)');
ylabel('BER (%)');
grid on;

function segnale_ricevuto = simulazione_canale(segnale_trasmesso, distanza)
    % Parametri del canale
    fc = 2.4e9; % Frequenza del canale (2.4 GHz per Bluetooth)
    c = 3e8; % Velocità della luce
    lambda = c / fc; % Lunghezza d'onda
    
    % Attenuazione del segnale (path loss)
    path_loss = (4 * pi * distanza) / lambda;
    segnale_attenuato = segnale_trasmesso ./ path_loss; % Utilizzo dell'operatore di divisione
    
    % Fading (modello semplificato)
    fading_factor = abs(randn(size(segnale_attenuato)));
    segnale_fading = segnale_attenuato .* fading_factor;
    
    % Convertire il segnale_fading in tipo numerico
    segnale_fading = double(segnale_fading);
    
    % Rumore termico (AWGN)
    SNR_dB = 20; % Rapporto segnale/rumore desiderato (in dB)
    segnale_ricevuto = awgn(segnale_fading, SNR_dB, 'measured');
end
