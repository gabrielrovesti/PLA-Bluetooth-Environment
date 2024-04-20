function BER = Sim()
%% Blocco messaggio inviato autentico
    % Creazione di un oggetto RSA per mischiare chiave con messaggio
    rsa = RSA();
    
    % Numero di trasmissioni da simulare
    N = 100; 
    
    % Generazione potenza di trasmissione e di chiave (in milliwatt)
    % Assumiamo che un generico canale wireless applichi questi parametri,
    % convenzionalmente fissati a quel Bluetooth
    % (distanze ridotte/potenza ridotta)
    potenza_dato = randi([-20, 20], 1, N); % Potenza di trasmissione
    
    % Generazione dati e chiavi casuali per tutte le trasmissioni a 100 bit
    dato = randi([0,1], 1, 100); 
    % dato = randi([0,1], 100); % Questo per rendere segnale diverso per 100 distanze
    
    % Criptare il messaggio dato utilizzando la chiave pubblica
    dato_crittato = rsa.encrypt(dato);

    % Rapporto segnale-rumore (SNR) desiderato in dB (utile per filtraggio)
    snr_db = 10; 
    
    % Conversione del SNR in scala lineare
    snr = 10^(snr_db/10);

    % Invio del segnale corretto con certa potenza mischiato con chiave RSA
    segnale_inviato = dato_crittato .* 10.^(potenza_dato/20);

    % Calcolo della potenza del rumore in base al segnale e al SNR
    potenza_rumore = sum(abs(segnale_inviato).^2) / length(segnale_inviato) / snr;

    % Generazione del rumore AWGN
    rumore = sqrt(potenza_rumore/2) * randn(size(segnale_inviato));
    
    % Impacchettamento segnale con rumore
    segnale_inviato = segnale_inviato + rumore;
%%

    %% Blocco messaggio inviato come non autentico
    % Caso migliore per attaccante: conosce tutti i parametri
    
    % Generazione nuovo dato casuale = implica il ragionamento che
    % l'attaccante possa avere un dato, anche parziale, rispetto alla
    % trasmissione originale
    dato_non_autentico = randi([0, 1], 1, 100); % Nuovo dato casuale di 100 bit
    
    % Creazione nuova istanza di RSA; l'attaccante potrebbe conoscere il
    % metodo autenticativo presente sul canale, ma di per sé l'istanza di
    % RSA è la stessa data la chiave pubblica presente. Cambiando il dato
    % dovrebbe essere riconosciuto in fase di decrittazione
    
    % Ideale = tiene la stessa potenza e considera la presenza di aggiunta
    % del rumore per poi essere trovato dal destinatario, quindi ripulito
    segnale_non_autentico = dato_non_autentico .* 10.^(potenza_dato/20);

    segnale_non_autentico = segnale_non_autentico + rumore;
%%

    % Vettori di simulazione
    distanza = [];
    segnale_ricevuto = [];
    segnale_filtrato = [];
    messaggio_decodificato = [];
    num_bit_errati = 0;
    num_bit_corretti = 0;

    % False alarm e missed detection
    FA = 0;
    MD = 0;

    false_alarm_prob = 0;
    missed_detection_prob = 0;

    % "x" = vettore delle soglie dinamiche, riempito con l'analisi delle medie sui dati
    x = [0.49, 0.47, 0.49, 0.48, 0.49, 0.50, 0.49, 0.48, 0.49, 0.49, 0.51, 0.48, 0.49, 0.49, 0.49, 0.49, 0.47, 0.49, 0.49, 0.49, 0.49, 0.48, 0.48, 0.48, 0.51, 0.49, 0.50, 0.49, 0.48, 0.48];
    
    % Mandare il segnale e ricalcolo segnale al ricevitore (decodifica)
    % Threshold iniziali e verifichiamo quanto il segnale con rumori disti 
    
    for i = 1:30  % Poiché 150/5 = 30
        
        % Calcola la nuova distanza
        if i == 1
            distanza(i) = 5;
        else
            distanza(i) = distanza(i-1) + 5;
        end
        
        % Effetto canale su segnale ricevuto corretto (disturbato dal rumore di fondo del canale)
        segnale_ricevuto = simulazione_canale(segnale_inviato, distanza(i));

        % Invio messaggio non autentico
        % segnale_ricevuto = simulazione_canale(segnale_non_autentico, distanza(i));

        % Filtro del rumore e normalizzazione per togliere rumore condiviso
        % e prendere il segnale integro (bassa frequenza)
        % rispetto a rumore e interferenza (alta frequenza)
    
        % Azzerando ad ogni iterazione, bit errati per la trasmissione (i)
        % altrimenti numero di bit sulle migliaia (30 * 100 = 3000)
        num_bit_errati = 0;
        % Se non azzeriamo, viene il grafico direttamente propozionale BER
        % (= retta)
    
        % Assumendo la trasmissione come autentica a priori, 
        % il SNR condiziona la scelta del filtro al destinatario, essendo
        % parametro noto in quanto inviato contestualmente al segnale con
        % aggiunta di rumore bianco

        ordine_filtro = 10; % Come separiamo le frequenze
        frequenza_norm = 0.3; % Normalizzazione = tagliare il segnale da una certa soglia
        filtro_low_band = fir1(ordine_filtro, frequenza_norm); % Taglio del segnale finito (FIR) per filtrarlo su coefficienti
    
        segnale_filtrato = filter(filtro_low_band, 1, segnale_ricevuto);
    
        % Soglie dinamiche su segnale ricevuto giusto (filtrato)
        p_min_fs = min(segnale_filtrato);
        p_max_fs = max(segnale_filtrato);
        
        % Se azzeriamo, vale per 100 bit per la trasmissione (i)
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
        
        % Controllo del messaggio rispetto alle soglie "center"
        if BER(i) <= x(i)
            % Messaggio autentico = mando solo messaggi autentici (plot 1)
            MD = MD + 1;
        elseif BER(i) > x(i) 
            % Messaggio non autentico = mando solo messaggi non autentici (plot 2)
            FA = FA + 1;
        end
    end

    % Se variassimo tutte le distanze con tutti i messaggi
    % fa_probs = zeros(1, 30);
    % md_probs = zeros(1, 30);

    FA_prob = FA / 30;
    MD_prob = MD / 30;

    % Non riusciamo a fare il plot completo in quanto è una percentuale
    % (se variasse per tutte le distanze il dato inviato allora si
    % riuscirebbe a fare anche questo)

    % False alarm = Messaggi giusti interpretati come sbagliati (falsi
    % positivi) sul numero di messaggi totali inviati. Questo è una
    % percentuale
    
    % Missed detection = Messaggi sbagliati interpretati come giusti
    % (rilevazioni scorrette - misdetections) sul numero di messaggi totali inviati. 
    % Questo è una percentuale

    % Decriptare il messaggio una volta che il messaggio è autentico sulla
    % base del precedente avviene con RSA; "il messaggio è autentico,
    % decritta solo quello corretto
    
    % Messaggio_decrittato = rsa.decrypt(segnale_ricevuto);
    
    %% Plot messaggi autentici
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
    % Plot FA e MD
    % figure;
    % plot(MD_prob, FA_prob, '-o');
    % xlabel('Probabilità di Missed Detection');
    % ylabel('Probabilità di False Alarm');
    % title('Curva ROC - FP / FN ');
    % grid on;

    %% Plot messaggi non autentici
    % 
    % % Flusso di bit trasmesso nel tempo (convertito in vettore)
    % tempo = 1:length(segnale_inviato);
    % 
    % % Plot del segnale originale e del segnale ricevuto
    % figure;
    % 
    % % Plot del segnale trasmesso
    % subplot(2, 2, 1);
    % plot(tempo, segnale_non_autentico, 'LineWidth', 2);
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
end
