% Parametri di trasmissione
N = 100; % Numero di trasmissioni da simulare

% Generazione potenza di trasmissione e di chiave (in milliwatt)
p_tx = randi([1, 10], 1, N); % Potenza di trasmissione
p_key = randi([1, 10], 1, N); % Potenza di chiave

% Inizializzazione di dati e chiavi per tutte le trasmissioni
dato = zeros(N, 100); % Dati trasmessi (matrice Nx100)
chiave = zeros(N, 100); % Chiavi (matrice Nx100)

% Generazione dati e chiavi casuali per tutte le trasmissioni
for i = 1:N
    dato(i, :) = randi([0, 1], 1, 100); % Dato (100 bit)
    chiave(i, :) = randi([0, 1], 1, 100); % Chiave (100 bit)
end

% Calcolo potenze minime e massime per dati e chiavi
p_min_dato = min(dato, [], 2); % Minimo per ogni riga
p_max_dato = max(dato, [], 2); % Massimo per ogni riga
p_min_chiave = min(chiave, [], 2); % Minimo per ogni riga
p_max_chiave = max(chiave, [], 2); % Massimo per ogni riga

% Trasformazione sinuisoidale dei dati e delle chiavi
A = 1; % Amplitude
f = 10; % Frequenza (Hz)

dato_sin = A * sin(2 * pi * f * dato); % Dati sinuisoidali
chiave_sin = A * sin(2 * pi * f * chiave); % Chiavi sinuisoidali

% Calcolo delle potenze sui segnali sinuisodali
p_potenza_dato_sin = mean(dato_sin.^2, 2); % Potenza dei dati sinuisoidali
p_potenza_chiave_sin = mean(chiave_sin.^2, 2); % Potenza delle chiavi sinuisoidali

