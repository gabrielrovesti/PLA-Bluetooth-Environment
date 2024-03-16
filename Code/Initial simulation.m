% Parametri della simulazione
fs = 1000; % Frequenza di campionamento (Hz)
durata = 1; % Durata del segnale in secondi
t = 0:1/fs:durata-1/fs; % Vettore del tempo

% 1. Generare il segnale di messaggio (es. bit di input)
bit_input = randi([0, 1], 1, length(t)); % Genera una sequenza casuale di bit

% 2. Generare il segnale di potenza (forma sinusoidale)
frequenza_messaggio = 10; % Frequenza del segnale di messaggio (Hz)
amplitude_messaggio = 1; % Amplitude del segnale di messaggio
messaggio = amplitude_messaggio * sin(2*pi*frequenza_messaggio*t);

% 3. Generare il segnale di autenticazione (ad esempio, rumore casuale)
autenticazione = randn(size(t));

% 4. Sovrapporre il segnale di messaggio al segnale di autenticazione
segnale_completo = messaggio + autenticazione;

% 5. Decodificatore per interpretare il segnale originale e il segnale di autenticazione
% Per questa parte, è necessario definire un algoritmo di decodifica che dipende dal tipo di segnale di autenticazione utilizzato.

% Esempio segnale ricevuto
segnale_dati = segnale_completo - autenticazione;

% Visualizzazione
figure;
subplot(3,1,1);
plot(t, bit_input);
title('Segnale di input (Bit)');
xlabel('Tempo (s)');
ylabel('Valore');

subplot(3,1,2);
plot(t, segnale_completo);
title('Segnale completo (Messaggio + Autenticazione)');
xlabel('Tempo (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, segnale_dati, 'b', t, autenticazione, 'r');
title('Segnale del ricevitore');
xlabel('Tempo (s)');
ylabel('Amplitude');
legend('Segnale Dati', 'Segnale Autenticazione');
