%% DFT CODICE PROGETTO
clc 
clear all 
close all
%% Acquired signals
% carico un file excel e seleziono una finestra temporale di analisi del
% segnale. 

dataset = xlsread(''); % inserisco il segnale che voglio analizzare
y = dataset(:,2);      % seconda colonna dell'excel con i dati
N = length(y);         % definisco la lunghezza --> numero campioni necessari per
                       % la normalizzazione --> non presente nella fft
t = dataset(:,1);      % prima colonna dell'excel che mi da il vettore del tempo
dt = t(2)-t(1);        % definisco delta t
fs = 1/dt;             % da delta t, la distanza tra due campioni, posso 
                       % definire la fs

figure
plot(t,y,'b')
xlabel('Time [s]')
ylabel('Amplitude')
title('Acquired signal time history')

disp('--- Signal selection ---')
disp('1 = select with mouse (ginput)')
disp('2 = enter start and end times manually')
disp('3 = enter start time and number of points manually')
modeSel = input('Select mode (1/2/3): ');

switch modeSel
     case 1  % Mouse selection
         figure(1)
         [px,~]=ginput(2);
         pin = px(1); 
         pfi = px(2);

     case 2  % Manual start/end
         pin = input('Enter start time [s]: ');
         pfi = input('Enter end time [s]: ');

     case 3  % Start time + number of points
         pin = input('Enter start time [s]: ');
         Np  = input('Enter number of points: ');
         [~,indStart] = min(abs(t-pin));
         indEnd = indStart + Np - 1;
         indEnd = min(indEnd,length(t));
        te = t(ind_in:ind_fi);   % extracted time vector
        ye = y(ind_in:ind_fi);   % extracted signal
        ne = length(ye);

 end

 if modeSel==1 || modeSel==2
     ind_in = find(t>pin);
     ind_fi = find(t<pfi);
     te = t(ind_in(1):ind_fi(end));
     y = y(ind_in(1):ind_fi(end));
     ne = length(y);
 end

 figure
 plot(te,y,'r-')
 xlabel('Time [s]')
 ylabel('Acceleration [m/s^2]')
 title('Extracted signal time history')


%% 3) FFT computation
% Compute the Discrete Fourier Transform (DFT)
Y = fft(y);        % FFT complex-valued su tutto il segnale finestrato y (double-sided, lunghezza pari a length(y)).

%  Commento di teoria:
%  La FFT di un segnale reale è coniugata-simmetrica: la parte negativa è lo specchio della positiva.
%  Il primo elemento (k=0) è la componente continua (DC), reale.
%  Se N è pari, l'elemento a frequenza di Nyquist (k=N/2) è anch'esso reale.
%  Oltre Nyquist compaiono i coniugati, speculari delle frequenze positive.

n = length(y);     % Numero di punti usati nella FFT (qui coincide con ne se hai ritagliato y sopra).

% Keep only the positive frequency part, shotrtening the Y vector. here I
% spit between the two cases, posso tenere solo la parte positiva, non è
% necessario tenerle entrambe, l'unica cosa devo stare attenta se ho numeri
% pari o dispari perchè altrimenti ho nyquist da qualche parte e me la
% perdo, tengo la parte positiva + l'eventuale frequenza di nyquist
% riducendo il numero di punti di circa la metà. 
if mod(n,2)==1
    Y = Y(1:round(n/2));      % N dispari: prendi fino a (N-1)/2 + 1 elementi (solo le positive, senza Nyquist).
else
    Y = Y(1:round(n/2)+1);    % N pari: includi anche la riga di Nyquist (indice N/2+1 in MATLAB).
end

% A questo punto il vettore Y è "single-sided": metà dei valori (circa), includendo DC e, se N pari, Nyquist.

% Amplitude normalization: la fft non la fa, lo devo far io per non perder
% info. we double the amplitude of the vectors. siccome abbiamo tenuto solo
% metà vettori devo moltiplicare pr due per non perdere in frequenza
%
% Normalizzazione standard single-sided:
% - moltiplica per 2/N le righe interne
% - dimezza DC e (se presente) Nyquist per conservare l'energia complessiva
Y = 2*Y/n; % Scala base 2/N per compensare il fatto che abbiamo tenuto solo la metà positiva.
           % Inoltre divide per N per avere ampiezze coerenti con Parseval.
Y(1) = Y(1)/2; % Corregge la riga DC (appare una sola volta nello single-sided).
               % Nota nel commento originale: "i should not divide the first element" — in realtà
               % si DEVE dividere per mantenere la conservazione dell'energia nel passaggio a single-sided.

% Se N è pari, la riga di Nyquist è presente una sola volta nello single-sided: va dimezzata come la DC.
if mod(n,2)==0  
    Y(end) = Y(end)/2; % Correzione della riga di Nyquist per conservare l'energia.
end

% Frequency vector
% df è la risoluzione in frequenza = 1/T, con T durata del segnale analizzato.
% TODO/FIX: qui 'T' non è definita nel codice. Dovrebbe essere T = n*dt (dopo l'eventuale finestra).
df = 1/T;                     % Frequency step [Hz] (ATTENZIONE: definire prima T = n*dt)
frax = [0:length(Y)-1]*df;    % Asse delle frequenze per lo single-sided (da 0 a ~fs/2 a passi df).
% Ogni elemento di 'frax' è un multiplo intero di df.

%% 4) Results plot
% Plot amplitude and phase spectra
figure
subplot(2,1,1)
stem(frax,abs(Y),'b','filled')   % Modulo dello spettro single-sided (ampiezze per frequenza).
xlabel('Frequency [Hz]')
ylabel('Amplitude')
title('Amplitude spectrum')

subplot(2,1,2)
stem(frax,angle(Y),'b','filled') % Fase dello spettro single-sided (in radianti).
xlabel('Frequency [Hz]')
ylabel('Phase [rad]')
title('Phase spectrum')
