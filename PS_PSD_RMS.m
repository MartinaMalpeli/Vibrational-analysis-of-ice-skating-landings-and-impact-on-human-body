%% Data Analysis for Mechanical Systems
% PS, PSD and RMS analysis — VERSIONE COMMENTATA
clc
clear all
close all

%% Acquired signals: segnale preso da noi
% carico i dati e definisco i parametri di campionamento
dataset = xlsread('random.xlsx');

yn = dataset(:,2);
N = length(yn);         % numero di campioni
fs = 10000;             % [Hz] Sampling frequency
dts = 1/fs;             % definisco l'intervallo temporale di campionamento
t = 0:dts:(N-1)*dts;    % Time vector

% segnale nel dominio del tempo
figure
plot(t,yn,'b')
xlabel('Time [s]')
ylabel('Amplitude')
title('Time domain')
grid on

%% Time window selection: selezione della finestra temporale
disp('--- Signal selection ---')
disp('1 = select with mouse (ginput)')
disp('2 = enter start and end times manually')
disp('3 = enter start time and number of points manually')
modeSel = input('Select mode (1/2/3): ');

switch modeSel
    case 1  % Mouse selection
        figure(1)
        [px,~] = ginput(2);
        pin = px(1);
        pfi = px(2);

    case 2  % Start + end times
        pin = input('Enter start time [s]: ');
        pfi = input('Enter end time [s]: ');

    case 3  % Start time + number of points
        pin = input('Enter start time [s]: ');
        Np  = input('Enter number of points: ');
        % --- TODO: complete index selection ---
        [~,indStart] = min(abs(t-pin));
        indEnd = min(indStart + Np - 1, length(t));
        te = t(indStart:indEnd);
        yn = yn(indStart:indEnd);
        N = length(yn);
end

% For methods 1 and 2:
if modeSel==1 || modeSel==2
    ind_in = find(t>pin);
    ind_fi = find(t<pfi);
    te = t(ind_in(1):ind_fi(end));
    yn = yn(ind_in(1):ind_fi(end));
    N = length(yn);
end

% Plot selected signal
figure
plot(te,yn,'r-')
xlabel('Time [s]')
ylabel('Amplitude')
title('Extracted time history')
grid on

T = length(te)*dts;

%% --- RMS from time domain ---
% TODO: compute RMS of the extracted signal in time domain
x_rms_time = sqrt(mean(yn.^2)); % proprio dalla definizione di RMS
fprintf('RMS (time domain) = %.4e\n', x_rms_time)

%% --- Complete spectrum ---
% TODO: compute FFT, PS and PSD of the complete time record
% Calcolo della FFT, dello spettro di potenza (PS) e della densità spettrale (PSD)
% dell'intero segnale temporale "yn"

n = length(yn);                      % Numero di campioni del segnale
Yc_full = fft(yn)/n;                 % FFT normalizzata per n: ottengo le ampiezze corrette
PS_full = conj(Yc_full).*Yc_full;    % Power Spectrum (modulo quadro del segnale in frequenza)
% NOTA: qua sto tenendo TUTTI i valori, non ho ancora diviso

% --- TODO: keep only the positive frequencies (single-sided spectrum) --- 
% I segnali reali hanno uno spettro simmetrico (parte negativa = coniugato della positiva)
% Quindi si può considerare solo metà dello spettro, correggendo poi le ampiezze.

if mod(n,2)==1 
    % n DISPARI: non esiste il bin di Nyquist. Prendo fino a (n+1)/2.
    % Tengo fino a (n+1)/2
    Yc = Yc_full(1:round(n/2));
    PS = PS_full(1:round(n/2));

else 
    % n PARI: esiste il bin di Nyquist. Prendo fino a n/2 + 1 (inclusi DC e Nyquist).
    % Tengo fino a n/2 + 1 (includo DC e Nyquist)
    Yc = Yc_full(1:round(n/2)+1); 
    PS = PS_full(1:round(n/2)+1);
end

% --- Correzione di ampiezza per lo spettro mono-lato ---
% Raddoppio i contributi interni per conservare l'energia totale (mono-lato):
% DC NON si raddoppia, Nyquist (se n pari) NON si raddoppia

% Poiché ho eliminato la metà negativa dello spettro, raddoppio le componenti
% positive (eccetto DC e Nyquist) per mantenere la stessa energia totale.

% raddoppio temporaneamente tutto
Yc = 2*Yc; 
PS = 2*PS;

% Correggo le componenti DC (frequenza 0) e Nyquist (se presente)Yc(1) = Yc(1)/2;
PS(1) = PS(1)/2;

if mod(n,2)==0 
    % se n è PARI, anche il bin di Nyquist non va raddoppiato
    Yc(end) = Yc(end)/2;
    PS(end) = PS(end)/2;
end

% --- Calcolo asse delle frequenze e densità spettrale ---
df = 1/T;                            % risoluzione in frequenza (1 / durata del segnale)
frax_c = (0:length(Yc)-1)*df;        % asse delle frequenze (per lo spettro mono-lato)
PSD = PS/df;                         % Power Spectral Density (W/Hz o unit^2/Hz)

%% --- RMS from spectra ---
% Calcolo dell'RMS (valore efficace) usando le informazioni spettrali
% TODO: compute RMS from double-sided and single-sided spectra

% RMS dal doppio-lato: uso tutto lo spettro originale
% (somma dei moduli al quadrato divisa per n^2)
x_rms_doublesided = sqrt(sum(abs(Yc_full).^2));  
 
% RMS dal mono-lato: stessa energia, ma dopo la correzione dei raddoppi
x_rms_singlesided = sqrt(sum(PS));   % Somma del power spectrum mono-lato

fprintf('RMS (double-sided FFT) = %.4e\n', x_rms_doublesided)
fprintf('RMS (single-sided FFT)  = %.4e\n', x_rms_singlesided)

%% --- Averaged spectrum (10 averages) ---
na = 10;                     % numero degli averages
n1 = floor(N/na);            % lunghezza intera di ogni sotto-sequenza
T1 = n1*dts;                 % durata di ciascun blocco

% TODO: segment the signal and compute FFT and PS for each block
% Segmentazione del segnale e calcolo FFT e PS per ogni blocco (double-sided)

for ii = 1:na
    % FFT di ciascun segmento e spettri associati (double-sided)
    % Creo matrici dove ogni riga è lo spettro del blocco ii-esimo
    Yds_i = fft(yn((ii-1)*n1+1:(ii*n1)))/n1;
    Ps_i  = conj(Yds_i).*Yds_i;
    Yds_av1(ii,:) = Yds_i;
    PS_av1(ii,:)  = Ps_i;
end

% È preferibile eseguire la media sullo spettro double-sided.
% Costruisco gli spettri single-sided per ciascun segmento prima di scalare le ampiezze

for ii = 1:na
    if mod(n1,2)==1
        % n1 DISPARI: non c'è il bin di Nyquist. Tengo fino a (n1+1)/2.
        Y1(ii,:)  = Yds_av1(ii, 1:round(n1/2));
        PS1(ii,:) = PS_av1(ii, 1:round(n1/2));
    else
        % n1 PARI: esiste il bin di Nyquist. Tengo fino a n1/2 + 1 (DC e Nyquist inclusi).
        Y1(ii,:)  = Yds_av1(ii, 1:round(n1/2)+1);
        PS1(ii,:) = PS_av1(ii, 1:round(n1/2)+1);
    end
end

% Adjust amplitudes
% Correzione delle ampiezze per il passaggio a single-sided:
% raddoppio i bin interni, lasciando invariati DC e Nyquist (se presente)
Y1 = 2*Y1; 
PS1 = 2*PS1;
Y1(:,1) = Y1(:,1)/2;  % DC non si raddoppia
PS1(:,1) = PS1(:,1)/2;

if mod(n1,2)==0  % se n1 è PARI, anche il bin di Nyquist (ultimo) non si raddoppia
    Y1(:,end)=Y1(:,end)/2;
    PS1(:,end)=PS1(:,end)/2;
end

% Asse delle frequenze del blocco e PSD media sui blocchi
df = 1/T1;                      % risoluzione in frequenza del blocco
frax1 = [0:size(Y1,2)-1]*df; % second frequency vector, vettore delle frequenze (single-sided)
PSD1 = mean(PS1)/df; % computation outside the loops, PSD media (media sui blocchi, normalizzata per df) 

% --- RMS for each subrecord (10 averages) ---
% computation of the RMS for each subhistories to be sure that everything
% is stable and alright. 

for ii = 1:na
    rms_time_10(ii) = sqrt(mean(yn((ii-1)*n1+1:(ii*n1)).^2));
end
rms_time_avg_10 = mean(rms_time_10);
fprintf('Average RMS (time domain, 10 averages) = %.4e\n', rms_time_avg_10)

%% --- Averaged spectrum (100 averages) ---
% copy poaste to see if the avarage is ok
na = 100;
n2 = floor(N/na);
T2 = n2*dts; 

% TODO: repeat the same process for 100 averages, stessa identica cosa
% fatta sopra semplicemente per 100 finestre
for ii = 1:na
    Yds_i = fft(yn((ii-1)*n2+1:(ii*n2)))/n2;
    Ps_i  = conj(Yds_i).*Yds_i;
    Yds_av2(ii,:) = Yds_i;
    PS_av2(ii,:)  = Ps_i;
end


for ii = 1:na
    if mod(n2,2)==1
        Y2(ii,:)  = Yds_av2(ii, 1:round(n2/2));
        PS2(ii,:) = PS_av2(ii, 1:round(n2/2));
    else
        Y2(ii,:)  = Yds_av2(ii, 1:round(n2/2)+1);
        PS2(ii,:) = PS_av2(ii, 1:round(n2/2)+1);
    end
end

% Adjust amplitudes
Y2=2*Y2; 
PS2=2*PS2;
Y2(:,1)=Y2(:,1)/2; PS2(:,1)=PS2(:,1)/2;
if mod(n2,2)==0 
    Y2(:,end)=Y2(:,end)/2;
    PS2(:,end)=PS2(:,end)/2;
end
df = 1/T2;
frax2 = [0:size(Y2,2)-1]*df;
PSD2 = mean(PS2)/df;

% --- RMS for each subrecord (100 averages) ---
for ii = 1:na
    rms_time_100(ii) = sqrt(mean(yn((ii-1)*n2+1:(ii*n2)).^2));
end
rms_time_avg_100 = mean(rms_time_100);
fprintf('Average RMS (time domain, 100 averages) = %.4e\n', rms_time_avg_100)

%% --- Plot PS and PSD ---
figure
semilogy(frax_c,PS,frax1,mean(PS1),frax2,mean(PS2))
xlabel('Frequency [Hz]')
ylabel('Amplitude [EU^2]')
legend('No averages','10 averages','100 averages')
title('Power Spectrum (PS)')
grid on

figure
semilogy(frax_c,PSD,frax1,PSD1,frax2,PSD2)
xlabel('Frequency [Hz]')
ylabel('Amplitude [EU^2/Hz]')
legend('No averages','10 averages','100 averages')
title('Power Spectral Density (PSD)')
grid on
