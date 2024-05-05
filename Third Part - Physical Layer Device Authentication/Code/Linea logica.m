%{

n_round = numer of times repeat a simulation with fixed settings

A1+ = potenza bit 1 segnale dato
A1- = potenza bit 0 segnale dato

A2+ = potenza bit 1 segnale auth
A2- = potenza bit 0 segnale auth

std_th+ = a1+
std_th- = a1-

SNR = [snr1, snr2, ....., snr_n]
- valori tipici di SNR in sistemi wireless possono variare da 0 dB (pessimo) a 30 dB (eccellente)
	- 10 dB minimo e tipico tra 20 e 30 dB
- l'SNR diminuisce con l'aumentare della distanza tra trasmettitore e ricevitore
= fisse per capire la copertura di affidabilità di una trasmissione
# https://web.stanford.edu/~dntse/Chapters_PDF/Fundamentals_Wireless_Communication_chapter5.pdf
distanza = [d1, d2, d3, ..., d_n]
target_FA = [fa1, fa2, ...., fa_n] -> intervalli 
	range deciso a priori = (fa1, fa1+epsilon)
	utile per capire se coi parametri di sim. dati si riesce ad ottenere una simulazione corretta
- definire intervalli di FA desiderati (ad esempio, 0,1%, 1%, 5%, ecc.)

target_MD= [md1, md2, ...., md_n] -> intervalli 

-----------------------
DEFINIZIONE DEL SEGNALE

x1 = sequenza bit dato
x2 = sequenza bit auth

s1 = segnale dato -> codificato in base ad A1+/-
s2 = segnale AUTH -> codificato in base ad A1+/-

S = s1 + s2
-------------------

STUDIO STRATEGIA DECODING
nota: soglie fisse
- for j in distance
-   for k in SNR
-       for i in range(1, N)
            DEFINIZIONE SEGNALE -> vedo in quale loop posizionare questo
            ricevitore -> awgn(segnale_generato, SNR)
            calcolo # bit errati con std_th -> sia per dato, che per auth
		(plot di fine pagine 2 come indicazione)
        
        calcolo BER medio

-> questo in base al BER delle diverse situazioni, decido strategia
decoding (quali valori della threshold di decoding uso)
BER = misura per correggere i settaggi del canale dato il segnale pilota per verificare precisione segnale e quanto

Il segnale deve essere "dentro" le soglie fisse
- sotto la soglia superiore
- sopra la soglia inferiore
Ergo = adattamento decodifica a seconda del BER
Se il BER è tanto alto, la codifica a soglie fisse non è più ottimale

----------------------
DECODING CON TH ADATTATE 
nota: soglie dinamiche (dipendenti dal segnale)
- devo individuare 4 valori medi di potenza -> mi aspetto che segnale anche
se scalato come ampiezza, mantenga circa lo stesso andamento del segnale
originale trasmesso.
- Trovo quindi 2 valori che corrispondono a: {dato = 1, (auth = 0, 1)} (T1', T2'), ed altri 2 valori che corrispondono a {dato = 0, (auth = 0, 1)} (T2', T3').
- ricavare le nuove threshold: T+, T-

- con le nuove threshold, in questo caso, calcolare nuovo BER come prima
BER stabile a prescindere dalla distanza

Per vedere se scelta threshold in modo dinamico sia stabile a prescindere dalla distanza (risultato atteso); prima, con threshold fisse, man mano che mi distanzio il BER cresca perché si ha più decadimento, segnale si sposta.

La BER misura di decodifica; troviamo quella giusta e calcoliamo FA e MD. 
----------

STUDIO FA, MD

FA (false alarm) = segnale autentico

- for j in distance
-   for k in SNR
        for f in target_FA
            for i in range(N)
                - creo segnal authed
                - trasmetto 
			(rumore canale e tutto)
                - decodifica
                - setto valore distanza hamming per decisione
                authentication (th)
                - verifica autentico?
            calcolo FA ottenuto
            -> ripeto finchè FA ottenuto è in range target (f)
                -> FA_Ottenuto > f -> aumento th 
			= pochi messaggi veri
                -> FA_Ottenuto < f -> riduco th
			= troppi messaggi veri
			come ridurre? valore precedente e valore nuovo, mi 			metto a metà
			(1.44.00 = fa_(t-1) e +1 della prima pagina)
			
            -> if FA_dh -> salvo th

(Ragionamento per miss detection dato il segnale autentico)

- for j in distance
-   for k in SNR
        for f in target_MD
		for T in th
			for i in N
			- generi il vettore di autenticazione
			- generi il segnale completamente sbagliato (non 			autentico)
			- ti assicuri sia diverso da quello corretto
			che definiamo noi come corretto
			- viene trasmesso
			stessa cosa di prima per capire quanti messaggi 			legittimi avendo generato tutto non legittimo?
			calcolo missed detection
			
			il valore di threshold dà la coppia FA/MD
			e li plotto

(Inizio resto codice)

MD (miss detection) = segnale non autentico
		
- for j in distance
-   for k in SNR
        for f in target_MD
            for i in range(N)
                - creo segnal non-authed
                - trasmetto 
			(rumore canale e tutto)
                - decodifica
                - utilizzo valore distanza hamming per decisione
                authentication (th)
                - verifica autentico?
            calcolo MD ottenuto
            -> ripeto finchè MD ottenuto è in range target (f)
                -> MD_Ottenuto > f -> riduco th 
			= troppi messaggi falsi
                -> MD_Ottenuto < f -> aumento th
			= pochi messaggi falsi

(Stessa roba)
Studio rumore = S + rumore artificiale
In questo modo, il MITM può tornare indietro?
Struttura di codice che Alessandro ha già.
%}