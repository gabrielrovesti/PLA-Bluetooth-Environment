%{

n_round = numer of times repeat a simulation with fixed settings

A1+ = potenza bit 1 segnale dato
A1- = potenza bit 0 segnale dato

A2+ = potenza bit 1 segnale auth
A2- = potenza bit 0 segnale auth

std_th+ = a1+
std_th- = a1-

SNR = [snr1, snr2, ....., snr_n]
distanza= [d1, d2, d3, ..., d_n]
target_FA= [fa1, fa2, ...., fa_n] -> intervalli (fa1, fa1+epsilon)

-----------------------
DEFINIZIONE DEL SEGNALE

x1 = sequenza bit dato
x2 = sequenza bit auth

s1 = segnale dato -> codificato in base ad A1+/-
s2 = segnale AUTH -> codificato in base ad A1+/-

S= s1 + s2

-------------------
STUDIO STRATEGIA DECODING
- for j in distance
-   for k in SNR
-       for i in range(1, N)
            DEFINIZIONE SEGNALE -> vedo in quale loop posizionare questo
            ricevitore -> segnale generato + awgn
            calcolo # bit errati con std_th -> sia per dato, che per auth
        
        calcolo BER medio


-> questo in base al BER delle diverse:  situazioni, decido strategia
decoding (quali valori della threshold di decoding uso)

----------------------
DECODING CON TH ADATTATE
- devo individuare 4 valori medi di potenza -> mi aspetto che segnale anche
se scalato come ampiezza, mantenga circa lo stesso andamento del segnale
originale trasmesso.
- Trovo quindi 2 volori che corrispondono a: {dato = 1, (auth = 0, 1)} (T1', T2'), e
altri 2 valori che corrispondono a {dato = 0, (auth = 0, 1)} (T2', T3').
- ricavare le nuove threshold: T+, T-

- con le nuove threshold, in questo caso, calcolare nuovo BER come prima


----------
STUDIO FA, MD

for ....
    for ....
        for f in target_FA
            for i in range(N)
                - creo segnal authed
                - trasmetto
                - decodifica
                - setto valore distanza hamming per decisione
                authentication (th)
                - verifica authentico?
            calcolo FA ottenuto
            -> ripeto finchè FA ottenuto è in range target (f)
                -> FA_Ottenuto > f -> aumento th
                -> FA_Ottenuto < f -> riduco t
            -> if FA_dh -> salvo th


%}

