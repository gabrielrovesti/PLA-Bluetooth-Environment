% Parametri di trasmissione
N = 100; % Numero di trasmissioni da simulare

% Generazione potenza di trasmissione e di chiave (in milliwatt)
p_tx = randi([-20, 20], 1, N); % Potenza di trasmissione
p_key = randi([-20, 20], 1, N); % Potenza di chiave

% Inizializzazione di dati e chiavi per tutte le trasmissioni
dato = zeros(N, 100); % Dati trasmessi (matrice Nx100)
chiave = zeros(N, 100); % Chiavi (matrice Nx100)

% Generazione dati e chiavi casuali per tutte le trasmissioni
for i = 1:N
    dato(i, :) = randi([0, 1], 1, 100); % Dato (100 bit)
    chiave(i, :) = randi([0, 1], 1, 100); % Chiave (100 bit)
end

segnale_trasmesso = trasmetti(dato, chiave, p_tx, p_key);

% Trasformazione in segnali sinusoidali
% (Formula da inserire)

function segnale_trasmesso = trasmetti(dato, chiave, p_tx, p_key)
    % Numero di trasmissioni
    N = size(dato, 1);

    % Inizializzazione del segnale trasmesso
    segnale_trasmesso = zeros(N, size(dato, 2));

    for i = 1:N
        % Modulazione di ampiezza (AM)
        segnale_trasmesso(i, :) = sqrt(10^(p_tx(i)/10)) * dato(i, :) .* sqrt(10^(p_key(i)/10)) .* chiave(i, :);
    end
end



