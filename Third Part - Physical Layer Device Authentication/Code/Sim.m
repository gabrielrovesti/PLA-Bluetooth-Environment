function BER = sim()

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
    
    % Contatori per falsi allarmi e mancate rilevazioni
    num_falsi_allarmi = 0;
    num_mancate_rilevazioni = 0;
    
    % Vettori per successivi ragionamenti
    distanza = [];
    segnale_ricevuto = [];
    segnale_filtrato = [];
    messaggio_decodificato = [];
    num_bit_errati = 0;
    num_bit_corretti = 0;
    
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
    
        % Azzerando ad ogni iterazione, bit errati per la trasmissione (i)
        % altrimenti numero di bit sulle migliaia (30 * 100 = 3000)
        num_bit_errati = 0;
        % Se non azzeriamo, viene il grafico direttamente propozionale BER
        % (=retta)
    
        ordine_filtro = 10; % Come separiamo le frequenze
        frequenza_norm = 0.3; % Normalizzazione = tagliare il segnale da una certa soglia
        filtro_low_band = fir1(ordine_filtro, frequenza_norm); % Taglio del segnale finito (FIR) per filtrarlo su coefficienti
    
        segnale_filtrato = filter(filtro_low_band, 1, segnale_ricevuto);
    
        % Soglie dinamiche su segnale ricevuto giusto (filtrato)
        p_min_fs = min(segnale_filtrato);
        p_max_fs = max(segnale_filtrato);
        
        % Se azzeriamo, vale per 100 bit per la trasmissione (i)
        % num_falsi_allarmi = 0;
        % num_mancate_rilevazioni = 0;
        % altrimenti numero di bit sulle migliaia (30 * 100 = 3000)
    
        % Decodifica bit per bit del segnale ricevuto con disturbo (per BER)
        for j = 1:length(segnale_filtrato)
    
            % Decodifica in forma segnale messaggio
            if segnale_filtrato(j) > 0
                if segnale_filtrato(j) > p_max_fs
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
    
            % Calcolo del numero di bit errati sul dato decodificato (0 e 1)
            % rispetto ad RSA (0 e 1)
            % Distanza di Hamming
            if messaggio_decodificato(j) ~= dato_crittato(j)
                num_bit_errati = num_bit_errati + 1;
            end
        end
    
        % Calcolo del BER per messaggio e chiave
        BER(i) = num_bit_errati / length(messaggio_decodificato);
    
        % Logica 
        % if BER(i) > x(i) then "Messaggio autentico"
        % else "Messaggio non autentico"
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
    
    %% Plot
    % 
    % % Flusso di bit trasmesso nel tempo (convertito in vettore)
    % tempo = 1:length(segnale_inviato);
    % 
    % % Plot del segnale originale e del segnale ricevuto
    % figure;
    % 
    % % Plot del segnale trasmesso
    % subplot(2, 2, 1);
    % plot(tempo, segnale_inviato, 'LineWidth', 2);
    % title('Segnale Trasmesso');
    % xlabel('Tempo');
    % ylabel('Ampiezza (dB)');
    % grid on;
    % 
    % % Plot del segnale ricevuto
    % subplot(2, 2, 2);
    % plot(tempo, segnale_ricevuto, 'LineWidth', 2);
    % title('Segnale Ricevuto');
    % xlabel('Tempo');
    % ylabel('Ampiezza (dB)');
    % grid on;
    % 
    % % Plot del segnale filtrato
    % subplot(2, 2, 3);
    % plot(tempo, segnale_filtrato, 'LineWidth', 2);
    % title('Segnale Filtrato');
    % xlabel('Tempo');
    % ylabel('Ampiezza (dB)');
    % grid on;
    % 
    % % Plot del BER per segnale dato
    % subplot(2, 2, 4);
    % plot(distanza, BER, '-o', 'LineWidth', 2);
    % title('Bit Error Rate (BER) per segnale dato + chiave');
    % xlabel('Distanza (m)');
    % ylabel('BER (%)');
    % grid on;
end
