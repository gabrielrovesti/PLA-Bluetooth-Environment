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
