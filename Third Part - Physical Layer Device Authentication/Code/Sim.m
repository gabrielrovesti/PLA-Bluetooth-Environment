clc;
clear all; close all;

% Creazione di un oggetto RSA
rsa_obj = RSA();

% Parametri di trasmissione
N = 100; % Numero di trasmissioni da simulare

% Generazione potenza di trasmissione e di chiave (in milliwatt)
potenza_dato = randi([-20, 20], 1, N); % Potenza di trasmissione
potenza_chiave = randi([-15, 15], 1, N); % Potenza di chiave

% Generazione dati e chiavi casuali per tutte le trasmissioni a 100 bit
dato = randi([0, 1], 1, 100); 
chiave = randi([0, 1], 1, 100); 

% Criptare il messaggio dato utilizzando la chiave pubblica
dato_crittato = rsa_obj.encrypt(dato);

% Invio del segnale con certa potenza con chiave pubblica (ricevente)
segnale_inviato = mix_signal(dato_crittato, chiave, potenza_dato, potenza_chiave);

% Calcolo delle threshold per decodifica
p_min_dato = min(potenza_dato);
p_max_dato = max(potenza_dato);
p_min_chiave = min(potenza_chiave);
p_max_chiave = max(potenza_chiave);

distanza = [];
received = [];
demixed_signal = [];
filtered_signal = [];
decoded_message = [];
decoded_key = [];
num_bit_errati = 0;

% Mandare il segnale e ricalcolo segnale al ricevitore (decodifica)
% Threshold iniziali e verifichiamo quanto il segnale con rumori disti 

for i = 1:30  % Poiché 150/5 = 30
    
    % Calcola la nuova distanza
    if i == 1
        distanza(i) = 5;
    else
        distanza(i) = distanza(i-1) + 5;
    end
    
    % Effetto canale su segnale ricevuto (disturbato)
    received = simulazione_canale(segnale_inviato, distanza(i));

    num_bit_errati_key = 0;
    num_bit_errati_mex = 0;

    % Filtro del rumore e normalizzazione per togliere rumore condiviso
    % e prendere il segnale integro (bassa frequenza)
    % rispetto a rumore e interferenza (alta frequenza)

    filter_order = 10; % Come separiamo le frequenze
    cutoff_frequency = 0.3; % Normalizzazione = tagliare il segnale da una certa soglia
    low_pass_filter = fir1(filter_order, cutoff_frequency); % Taglio del segnale finito (FIR) per filtrarlo su coefficienti

    filtered_signal = filter(low_pass_filter, 1, received);

    % Decodifica bit per bit del segnale ricevuto con disturbo
    for j = 1:length(filtered_signal)
        % Decodifica (cosa fare)

        % Decode the message
        if filtered_signal(j) > 0
            if filtered_signal > p_max_dato
                decoded_message(j) = 1;
            else
                decoded_message(j) = 0;
            end
        else
            if filtered_signal(j) < p_min_dato
                decoded_message(j) = 0;
            else
                decoded_message(j) = 1;
            end
        end

        % Decode the key
        if filtered_signal(j) > 0
            if filtered_signal(j) > p_max_chiave
                decoded_key(j) = 1;
            else
                decoded_key(j) = 0;
            end
        else
            if filtered_signal(j) < p_min_chiave
                decoded_key(j) = 0;
            else
                decoded_key(j) = 1;
            end
        end

        % Calcolo del numero di bit errati
        if decoded_key(j) ~= chiave(j)
            num_bit_errati_key = num_bit_errati_key + 1;
        end

        if decoded_message(j) ~= dato_crittato(j)
            num_bit_errati_mex = num_bit_errati_mex + 1;
        end
    end

    % Calcolo del BER per messaggio e chiave
    BER_message(i) = num_bit_errati_mex / length(decoded_message);
    BER_key(i) = num_bit_errati_key / length(decoded_key);
end

% Decrittare il messaggio utilizzando la chiave privata
messaggio_decripted = rsa_obj.decrypt(decoded_message);

% Messaggi autentici/non autentici/threshold

distanza = [];
for i = 1:30  % Poiché 150/5 = 30
    
    % Calcola la nuova distanza
    if i == 1
        distanza(i) = 5;
    else
        distanza(i) = distanza(i-1) + 5;
    end
end

% Creazione del vettore per l'asse temporale
tempo = 1:length(segnale_inviato);

% Plot del segnale originale e del segnale ricevuto
figure;

% Plot del segnale trasmesso
subplot(2, 2, 1);
plot(tempo, segnale_inviato, 'LineWidth', 2);
title('Segnale Trasmesso');
xlabel('Tempo');
ylabel('Ampiezza');
grid on;

% Plot del segnale ricevuto
subplot(2, 2, 2);
plot(tempo, received, 'LineWidth', 2);
title('Segnale Ricevuto');
xlabel('Tempo');
ylabel('Ampiezza');
grid on;

% Plot del segnale filtrato
subplot(2, 2, 3);
plot(tempo, filtered_signal, 'LineWidth', 2);
title('Segnale Filtrato');
xlabel('Tempo');
ylabel('Ampiezza');
grid on;

% Plot del BER per segnale dato
subplot(2, 2, 4);
plot(distanza, BER_message, '-o', 'LineWidth', 2);
title('Bit Error Rate (BER) per segnale dato');
xlabel('Distanza (m)');
ylabel('BER');
grid on;

function segnale_inviato = mix_signal(dato_crittato, chiave, potenza_dato, potenza_chiave)
    % Convert symbolic variables to numeric values
    dato_crittato = double(dato_crittato);
    chiave = double(chiave);

    % Verifica e adattamento delle lunghezze del dato casuale e della chiave di autenticazione
    if length(dato_crittato) > length(chiave)
        chiave = [chiave, zeros(1, length(dato_crittato) - length(chiave))];
    elseif length(dato_crittato) < length(chiave)
        chiave = chiave(1:length(dato_crittato));
    end
    
    % Inizializzazione del segnale mixato
    segnale_inviato = zeros(1, length(dato_crittato));
    
    % Mixaggio del dato con la chiave utilizzando l'operatore XOR
    for i = 1:length(dato_crittato)
        segnale_inviato(i) = bitxor(dato_crittato(i), chiave(i));
    end

    % Potenzia il segnale di dato con la potenza fornita - conversione in
    % dB
    segnale_inviato = segnale_inviato .* 10.^(potenza_dato/20);

    % Potenzia il segnale di chiave con la potenza fornita - conversion in
    % dB
    chiave_potenziata = chiave .* 10.^(potenza_chiave/20);

    % Mixaggio dei segnali di dato e chiave
    segnale_inviato = segnale_inviato + chiave_potenziata;
end

function received = simulazione_canale(segnale_trasmesso, distanza)
    % Parametri del canale
    fc = 2.4e9; % Frequenza del canale (2.4 GHz per Bluetooth)
    c = 3e8; % Velocità della luce
    lambda = c / fc; % Lunghezza d'onda
    
    % Attenuazione del segnale (path loss)
    path_loss = (4 * pi * distanza) / lambda;
	% https://en.wikipedia.org/wiki/Free-space_path_loss
    segnale_attenuato = segnale_trasmesso / path_loss;
    
    % Fading (modello semplificato)
	% https://it.mathworks.com/help/comm/ug/rayleigh-fading-channel.html
    fading_factor = abs(randn(size(segnale_attenuato)));
    segnale_fading = segnale_attenuato .* fading_factor;
    
    % Rumore termico (AWGN)
    SNR_dB = 20; % Rapporto segnale/rumore desiderato (in dB)
    received = awgn(segnale_fading, SNR_dB, 'measured');
end