% Parametri di trasmissione
N = 100; % Numero di trasmissioni da simulare

% Generazione potenza di trasmissione e di chiave (in milliwatt)
potenza_dato = randi([-20, 20], 1, N); % Potenza di trasmissione
potenza_chiave = randi([-15, 15], 1, N); % Potenza di chiave

% Generazione dati e chiavi casuali per tutte le trasmissioni a 100 bit
dato = randi([0, 1], 1, 100); 
chiave = randi([0, 1], 1, 100); 

% Invio del segnale con certa potenza
segnale_inviato = mix_signal(dato, chiave, potenza_dato, potenza_chiave);

% Calcolo delle threshold per decodifica
p_min_dato = min(potenza_dato);
p_max_dato = max(potenza_dato);
p_min_chiave = min(potenza_chiave);
p_max_chiave = max(potenza_chiave);


distanza = [];
received = [];
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

    % Inizializza variabili per il calcolo degli errori
    num_bit_errati_key = 0;
    num_bit_errati_mex = 0;

    % Decodifica bit per bit del segnale ricevuto con disturbo
    for j = 1:length(received)
        % Decodifica effettiva messaggio
        % Applicazione delle threshold per il messaggio
        if received(j) > 0
            if received(j) > p_max_dato
                decoded_message(j) = 1;
            else
                decoded_message(j) = 0;
            end
        else
            if received(j) < p_min_dato
                decoded_message(j) = 0;
            else
                decoded_message(j) = 1;
            end
        end

        % Decodifica effettiva chiave
        % Applicazione delle threshold per la chiave
        if received(j) > 0
            if received(j) > p_max_chiave
                decoded_key(j) = 1;
            else
                decoded_key(j) = 0;
            end
        else
            if received(j) < p_min_chiave
                decoded_key(j) = 0;
            else
                decoded_key(j) = 1;
            end
        end

        % Calcolo del numero di bit errati
        if decoded_key(j) ~= chiave(j)
            num_bit_errati_key = num_bit_errati_key + 1;
        end

        if decoded_message(j) ~= dato(j)
            num_bit_errati_mex = num_bit_errati_mex + 1;
        end
    end

    % Calcolo del BER per messaggio e chiave
    BER_message(i) = num_bit_errati_key / length(decoded_message);
    BER_key(i) = num_bit_errati_mex / length(decoded_key);
end

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

% Definizione delle soglie accettabili per le BER
x = linspace(min([media_BER_message, media_BER_key]), max([media_BER_message, media_BER_key]), length(BER_message)); % Interpolazione lineare per ottenere una soglia per ogni BER

% Calcolo della media delle BER per condizionare i falsi allarmi e le mancate rilevazioni
media_BER_message = mean(BER_message);
media_BER_key = mean(BER_key);

% Verifica se i messaggi sono autentici o no utilizzando le soglie
messaggi_autentici = false(size(BER_message)); 

for i = 1:length(BER_message) % Itera attraverso ogni distanza
    % Verifica se la BER è inferiore alla soglia accettabile
    if BER_message(i) <= x(i) && BER_key(i) <= x(i)
        messaggi_autentici(i) = true; % Segnale autentico
    else
        messaggi_autentici(i) = false; % Segnale non autentico
    end
end

% Visualizzazione dei risultati
disp('Stato di autenticità dei messaggi:');
disp(messaggi_autentici);

% Calcolo del tasso di false alarm per i messaggi autentici
false_alarm_rate = sum(BER_message > x(1)) / length(distanza);

% Calcolo del tasso di missed detection per i messaggi non autentici
missed_detection_rate = sum(BER_key <= x(1)) / length(distanza);

% Plot dei risultati
figure;
plot(missed_detection_rate, false_alarm_rate, 'ro', 'MarkerSize', 10);
title('Missed Detection vs False Alarm');
xlabel('Missed Detection Rate');
ylabel('False Alarm Rate');
grid on;

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

% Plot del BER per segnale dato
subplot(2, 2, 3);
plot(distanza, BER_message, '-o', 'LineWidth', 2);
title('Bit Error Rate (BER) per segnale dato');
xlabel('Distanza (m)');
ylabel('BER');
grid on;

% Plot del BER per segnale chiave
subplot(2, 2, 4);
plot(distanza, BER_key, '-o', 'LineWidth', 2);
title('Bit Error Rate (BER) per segnale chiave');
xlabel('Distanza (m)');
ylabel('BER');
grid on;

function segnale_inviato = mix_signal(dato, chiave, potenza_dato, potenza_chiave)
    % Verifica e adattamento delle lunghezze del dato casuale e della chiave di autenticazione
    if length(dato) > length(chiave)
        chiave = [chiave, zeros(1, length(dato) - length(chiave))];
    elseif length(dato) < length(chiave)
        chiave = chiave(1:length(dato));
    end
    
    % Inizializzazione del segnale mixato
    segnale_inviato = zeros(1, length(dato));
    
    % Mixaggio del dato con la chiave utilizzando l'operatore XOR
    for i = 1:length(dato)
        segnale_inviato(i) = bitxor(dato(i), chiave(i));
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

