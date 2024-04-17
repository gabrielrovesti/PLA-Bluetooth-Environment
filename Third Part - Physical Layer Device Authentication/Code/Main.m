clc;
clear;

% Numero di simulazioni da eseguire
numero_simulazioni = 10; % Modificare il numero di simulazioni desiderato

% Inizializzazione di una matrice per memorizzare i valori di BER di tutte le simulazioni
tutte_le_BER = zeros(numero_simulazioni, 30);

% Esecuzione delle simulazioni
for simulazione = 1:numero_simulazioni
    clc;
    disp(['Simulazione ', num2str(simulazione)]);
    
    % Chiamata alla simulazione
    BER = Sim();
    
    % Memorizzazione dei valori di BER
    tutte_le_BER(simulazione, :) = BER;
end

% Creazione del file Excel
workbook = actxserver('Excel.Application');
workbook.Visible = 1;
workbook.Workbooks.Add;
worksheet = workbook.ActiveSheet;

% Scrittura dei valori di BER per ogni simulazione nel foglio Excel
worksheet.Range('A1').Value = 'Distanza (m)';
for simulazione = 1:numero_simulazioni
    colonna_iniziale = 2 * (simulazione - 1) + 1; % Calcola la colonna iniziale per questa simulazione
    colonna_BER = colonna_iniziale + 1; % Colonna per i valori di BER
    
    worksheet.Range(sprintf('%s1', char('A' + colonna_iniziale))).Value = ['BER - Simulazione ', num2str(simulazione)];
    
    % Scrivi i valori di BER per questa simulazione
    for i = 1:length(BER)
        % Converti il numero della riga e della colonna in lettere per il formato di Excel
        colonna_excel = char('A' + colonna_BER);
        riga_excel = num2str(i+1); % Aggiungi 1 perché la prima riga è l'intestazione
        
        % Scrivi il valore di BER nel foglio Excel
        worksheet.Range([colonna_excel, riga_excel]).Value = tutte_le_BER(simulazione, i);
    end
end
