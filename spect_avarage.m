%% Data Analysis for Mechanical Systems
% Spectral averages - VERSIONE COMMENTATA
clc                      
clear all                
close all                

%% Acquired signals, quello utile per il progetto
% Carica il segnale da un file Excel (2 colonne attese: tempo e misura, o simile)
dataset = xlsread('micr.xlsx');   % Legge il foglio: qui si assume i dati siano numerici
yn = dataset(:,2);                % Estrae la seconda colonna come segnale (accelerazione, ecc.)
N = length(yn);                   % Numero di campioni del segnale caricato

fs = 2048;       % Frequenza di campionamento [Hz] (nota del sistema di acquisizione)
dts = 1/fs;      % Tempo di campionamento [s]
t = 0:dts:(N-1)*dts;  % Vettore dei tempi allineato al numero di campioni

% Visualizzazione del segnale completo
figure
plot(t, yn, 'b')
xlabel('Time [s]')
ylabel('Amplitude')
title('Time domain')

%% Time window selection (3 modes), prendo i dati e lo taglio come al solito
% Selezione di una finestra temporale del segnale in tre modalità:
% 1) con il mouse (ginput), 2) inserendo tempi di inizio/fine, 3) inizio + numero di punti
disp('--- Signal selection ---')
disp('1 = select with mouse (ginput)')
disp('2 = enter start and end times manually')
disp('3 = enter start time and number of points manually')
modeSel = input('Select mode (1/2/3): ');   % Richiesta modalità all'utente

switch modeSel
    case 1  % Selezione con mouse su figura 1 (due click: inizio e fine)
        figure(1)
        [px,~] = ginput(2);   % px contiene le ascisse (tempi) selezionate
        pin = px(1);          % Tempo iniziale selezionato
        pfi = px(2);          % Tempo finale selezionato

    case 2  % Inserimento manuale di inizio/fine (in secondi)
        pin = input('Enter start time [s]: ');
        pfi = input('Enter end time [s]: ');

    case 3  % Inserimento di inizio + numero di punti da estrarre
        pin = input('Enter start time [s]: ');
        Np  = input('Enter number of points: ');
        [~,indStart] = min(abs(t - pin));   % Indice del campione più vicino al tempo pin
        indEnd = indStart + Np - 1;         % Indice finale in base al numero di punti
        indEnd = min(indEnd, length(t));    % Protezione per non superare la lunghezza del segnale
        te = t(indStart:indEnd);            % Finestra temporale estratta
        yn = yn(indStart:indEnd);           % Segnale finestrato
        N = length(yn);                     % Aggiorna N alla nuova finestra

        % Nota: in questa modalità non servono pin/pfi perché si lavora con indici diretti
end

% Per le modalità 1 e 2: converte i tempi pin/pfi in indici e ritaglia il segnale
if modeSel == 1 || modeSel == 2
    ind_in = find(t > pin);         % Primo indice con tempo maggiore di pin
    ind_fi = find(t < pfi);         % Ultimo indice con tempo minore di pfi
    te = t(ind_in(1):ind_fi(end));  % Vettore tempi della finestra
    yn = yn(ind_in(1):ind_fi(end)); % Segnale finestrato
    N = length(yn);                 % Aggiorna N alla finestra
end

T = N * dts;     % Durata della finestra selezionata

% Grafico del segnale estratto (finestrato)
figure(2)
plot(te, yn, 'r-')
xlabel('Time [s]')
ylabel('Acceleration [m/s^2]')
title('Extracted signal time history')

%% Complete spectrum
% Calcolo dello spettro su tutto il segnale finestrato (FFT completa)
Yc = fft(yn);           % Trasformata di Fourier complessa (double-sided)
n = length(yn);         % Numero di punti usati per la FFT

% --- Selezione dello spettro a singola faccia (single-sided) ---
% Per segnali reali, lo spettro è simmetrico: si prende metà + DC (+ Nyquist se n pari)
if mod(n,2) == 1
    Yc = Yc(1:round(n/2));      % n dispari: fino al punto centrale escluso
else
    Yc = Yc(1:round(n/2)+1);    % n pari: include la riga di Nyquist
end

% --- Normalizzazione dell'ampiezza ---
% Si porta lo spettro single-sided su scala ampiezza corretta:
% 2/n per le righe interne, mentre DC e (eventuale) Nyquist vanno dimezzate.
Yc = 2 * Yc / n;        % Scala base 2/n
Yc(1) = Yc(1) / 2;      % Correzione della componente DC
if mod(n,2) == 0 
    Yc(end) = Yc(end) / 2;  % Correzione della componente di Nyquist (se presente)
end

% --- Vettore delle frequenze per lo spettro completo ---
df = 1/T;                                 % Risoluzione in frequenza [Hz]
frax_c = [0:length(Yc)-1] * df;           % Frequenze corrispondenti alle righe FFT

%% Averaged spectrum
% Media spettrale su segmenti: trade-off tra risoluzione in frequenza e riduzione del rumore.
na = 56;             % Numero di medie (segmenti)
n1 = floor(N / na);  % Lunghezza di ciascun segmento (in campioni), intera
Nuse = n1 * na;      % Numero di campioni effettivamente usati (multiplo intero)
yn = yn(1:Nuse);     % Troncamento del segnale alla lunghezza utilizzata
T1 = n1 * dts;       % Durata di un singolo segmento (per df di segmento)

% --- FFT per ciascun segmento (double-sided) ---
% Si scorre il segnale a blocchi consecutivi non sovrapposti di lunghezza n1
for ii = 1:na
    % Estrae il segmento i-esimo e calcola la sua FFT
    Yds(ii,:) = fft(yn((ii-1)*n1+1:(ii*n1)));
end

% --- Conversione a single-sided per ogni segmento ---
% Stesso criterio della FFT completa, ma applicato per riga (segmento)
for ii = 1:na
    if mod(n1,2) == 1
        Y(ii,:) = Yds(ii,1:round(n1/2));       % n1 dispari
    else
        Y(ii,:) = Yds(ii,1:round(n1/2)+1);     % n1 pari: include Nyquist
    end
end

% --- Normalizzazione dell'ampiezza per i segmenti ---
% Applica a ogni segmento la stessa correzione (2/n1, con DC e Nyquist dimezzate)
Y = 2 * Y / n1;          % Scala 2/n1 per tutte le righe tranne correzioni
Y(:,1) = Y(:,1) / 2;     % Correzione DC per tutte le medie
if mod(n1,2) == 0 
    Y(:,end) = Y(:,end) / 2;   % Correzione Nyquist se n1 è pari
end

% --- Vettore delle frequenze per gli spettri mediati ---
df = 1/T1;                              % Risoluzione in frequenza sul segmento
frax = [0:size(Y,2)-1] * df;            % Frequenze corrispondenti alle colonne di Y

% --- Calcolo delle medie spettrali ---
% Due tipi di media:
% 1) RMS (qui implementata come media del modulo: vedi nota sotto)
% 2) Media complessa (mantiene fase: utile per componenti coerenti)
%
% NOTA: La "RMS" qui è intesa come media del valore assoluto della single-sided FFT.
% In molti contesti si preferisce la media dell'energia (media del modulo^2) e poi sqrt.
% Qui si segue esplicitamente quanto indicato nei commenti originali.

% Media del modulo (tipo "RMS" operativo sul modulo della FFT single-sided)
for ii = 1:size(Y,2)
    Y_rms(ii) = mean(abs(Y(:,ii)));   % Media dei moduli sulle na realizzazioni
end

% Media complessa (mantiene informazione di fase, può attenuare componenti incoerenti)
for ii = 1:size(Y,2)
    Y_cmplx(ii) = mean(Y(:,ii));      % Media diretta dei numeri complessi
end

%% --- Repeat with 100 averages (optional) ---
% TODO: Ripetere la sezione di media spettrale impostando na = 100 e ricomputando.
% Osservare: aumentando na si riduce la varianza (rumore) ma peggiora la risoluzione in frequenza (df più grande).

%% --- RMS computations ---
% 1) RMS nel dominio del tempo
x_rms_time = sqrt(mean(yn.^2));

% 2) RMS da spettro double-sided
% Parseval per la definizione di fft() di MATLAB:
% sum(|x[n]|^2) = (1/N) * sum(|X[k]|^2)  ->  mean(x.^2) = (1/N^2)*sum(|X|^2)
Xds = fft(yn);                 % FFT double-sided del segnale corrente (dopo eventuale troncamento)
x_rms_fft_ds = sqrt( sum(abs(Xds).^2) ) / N;

% 3) RMS da spettro single-sided
% Ricostruisco una single-sided NORMALIZZATA come fatto sopra (2/N con DC/Nyquist dimezzate)
n_cur = length(yn);

% Selezione metà spettro
if mod(n_cur,2) == 1
    Yc_loc = Xds(1:round(n_cur/2));
else
    Yc_loc = Xds(1:round(n_cur/2)+1);
end

% Normalizzazione ampiezza single-sided coerente
Yc_loc = 2 * Yc_loc / n_cur;     % scala 2/N sulle righe interne
Yc_loc(1) = Yc_loc(1) / 2;       % dimezza DC
if mod(n_cur,2) == 0
    Yc_loc(end) = Yc_loc(end) / 2; % dimezza Nyquist se presente
end

% Con questa scala, vale: RMS = sqrt( 0.5 * sum(|Yc_loc|.^2) )
x_rms_fft_ss = sqrt( 0.5 * sum( abs(Yc_loc).^2 ) );

% --- Report dei risultati e delle differenze percentuali ---
err_ds = abs(x_rms_fft_ds - x_rms_time) / x_rms_time * 100;
err_ss = abs(x_rms_fft_ss - x_rms_time) / x_rms_time * 100;

fprintf('\n=== RMS comparison ===\n');
fprintf('Time-domain RMS          : %.6g\n', x_rms_time);
fprintf('FFT double-sided RMS     : %.6g  (err = %.3f %%)\n', x_rms_fft_ds, err_ds);
fprintf('FFT single-sided RMS     : %.6g  (err = %.3f %%)\n', x_rms_fft_ss, err_ss);
fprintf('Note: piccole discrepanze possono derivare da troncamenti, finestrature,\n');
fprintf('      o approssimazioni numeriche, ma dovrebbero restare molto piccole.\n\n');

%% Plot results
% Confronto tra:
% - Spettro completo single-sided (blu)
% - Media "RMS" (media dei moduli) sulle medie (rosso)
% - Media complessa sulle medie (verde)
figure
semilogy(frax_c, abs(Yc), '-b', ...
         frax, abs(Y_rms), 'r-', ...
         frax, abs(Y_cmplx), '-g')
legend('Complete','RMS','Complex')
title('Spectra')
xlabel('Frequency [Hz]')
ylabel('Amplitude [EU]')
grid on