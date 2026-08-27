
%% CALCOLO DELLA COERENZA COMMENTATO
% Questo script:
% 1) Legge due segnali da file Excel
% 2) Esegue un filtraggio passa-alto per rimuovere la componente molto bassa
% 3) Calcola spettri monolato dei segnali estratti e li visualizza
% 4) Calcola autospettri, cross-spettro e coerenza media su più medie
% (avaraging)

close all
clear all
clc

%% 1) Data-sets loading

dataset1 = xlsread('test_2');

% Definizione parametri segnale
acc = dataset1(:,2);   % accelerometro [m/s^2]
mic = dataset1(:,4);   % microfono [V]
N   = length(acc);     % numero campioni totali
fs  = 2048;            % frequenza di campionamento [Hz]
dts = 1/fs;            % passo temporale [s]
t   = 0:dts:(N-1)*dts; % vettore dei tempi [s]

% Visualizzazione del segnale completo NON filtrato (diagnostica iniziale)
figure
    subplot(2,1,1)
    plot(t,acc,'b-');
    xlabel('Time [s]')
    ylabel('Acceleration [m/s^2]')
    title('UN-filtered accelerometer signal time history');
    subplot(2,1,2)
    plot(t,mic,'b-');
    xlabel('Time [s]')
    ylabel('Signal amplitude [V]')
    title('UN-filtered microphone signal time history');

%% High pass filtering -----------------------------------------------------
% Filtro Butterworth 3° ordine passa-alto a 10 Hz per rimuovere offset/deriva

Wn = 10/(fs/2); % normalized cutoff frequency
[B,A] = butter(3,Wn,'high');
accf = filtfilt(B,A,acc);
micf = filtfilt(B,A,mic);

% Visualizzazione del segnale completo FILTRATO per confronto
figure
    subplot(2,1,1)
    plot(t,accf,'b-');
    xlabel('Time [s]')
    ylabel('Acceleration [m/s^2]')
    title('Filtered accelerometer signal time history');
    subplot(2,1,2)
    plot(t,micf,'b-');
    xlabel('Time [s]')
    ylabel('Signal amplitude [V]')
    title('Filtered microphone signal time history');
    
%% 2) Useful signals time window selection (3 methods)
% seleziono una porzione di segnale utile per l'analisi

disp('--- Signal selection ---')
disp('1 = select with mouse (ginput)')
disp('2 = enter start and end times manually')
disp('3 = enter start time and number of points manually')
modeSel = input('Select mode (1/2/3): ');

switch modeSel
    case 1  % --- Mouse selection ---
        figure
        plot(t,accf,'b'); 
        xlabel('Time [s]'); 
        ylabel('Acceleration [m/s^2]');
        title('Click twice to select accelerometer time window')
        [px,~] = ginput(2);
        pin = px(1);
        pfi = px(2);

    case 2  % --- Manual start/end ---
        pin = input('Enter start time [s]: ');
        pfi = input('Enter end time [s]: ');

    case 3  % --- Start time + number of points ---
        pin = input('Enter start time [s]: ');
        Np  = input('Enter number of points: ');
        [~,indStart] = min(abs(t - pin));
        indEnd = indStart + Np - 1;
        indEnd = min(indEnd, length(t));
        te = t(indStart:indEnd);
        acce = accf(indStart:indEnd);
        mice = micf(indStart:indEnd);
        ne = length(acce);
end

% --- For methods 1 and 2 ---
if modeSel == 1 || modeSel == 2
    ind_in = find(t > pin);
    ind_fi = find(t < pfi);
    te = t(ind_in(1):ind_fi(end));
    acce = accf(ind_in(1):ind_fi(end));
    mice = micf(ind_in(1):ind_fi(end));
    ne = length(acce);
end

% --- Selected window plot ---
figure
    subplot(2,1,1)
    plot(te, acce, 'r-');
    xlabel('Time [s]')
    ylabel('Acceleration [m/s^2]')
    title('Filtered accelerometer signal time history');
    subplot(2,1,2)
    plot(te, mice, 'r-');
    xlabel('Time [s]')
    ylabel('Signal amplitude [V]')
    title('Filtered microphone signal time history');
    
%% 3) Frequency domain — extracted signals spectra ------------------------
% Spettri monolato (single-sided) dei due segnali ESTRATTI (acce, mice)

T  = ne*dts;        % durata osservazione [s]
df = 1/T;           % risoluzione in frequenza [Hz]
f  = 0:df:(ne-1)*df;% asse frequenze completo (due-lati)

% NOTA: qui si usa una normalizzazione semplice (ne/2) per ottenere
% ampiezze monolato, ricomponendo la potenza sulle bin positive.
% Si dimezza anche la componente DC (indice 1) per coerenza.

ACCE = fft(acce)/(ne/2); 
ACCE(1) = ACCE(1)/2;     % correzione DC (evita raddoppio)
MICE = fft(mice)/(ne/2);
MICE(1) = MICE(1)/2;     % correzione DC

% Spettri: modulo e fase (si visualizza fino a fs/2)

figure
    subplot(2,1,1)
    plot(f,abs(ACCE));
    xlabel('Frequency [Hz]');
    ylabel('Amplitude [m/s^2]');
    title('Spectrum of the accelerometer extracted time history');
    xlim([0 fs/2]); 
    subplot(2,1,2)
    plot(f,angle(ACCE));
    xlabel('Frequency [Hz]');
    ylabel('Phase [rad]');
    xlim([0 fs/2]);

    % plotto quello che succede al microfono
figure
    subplot(2,1,1)
    plot(f,abs(MICE));
    xlabel('Frequency [Hz]');
    ylabel('Amplitude [V]');
    title('Spectrum of the microphone extracted time history');
    xlim([0 fs/2]); 
    subplot(2,1,2)
    plot(f,angle(MICE));
    xlabel('Frequency [Hz]');
    ylabel('Phase [rad]');
    xlim([0 fs/2]);

%% 4) Auto-spectra and Cross-spectrum evaluation --------------------------
% Si calcolano autospettri e cross-spettro mediando su 'na1' blocchi.
% Ogni blocco contiene 'n1' campioni contigui (senza sovrapposizione).
% NB: L''ultima parte della finestra selezionata può essere scartata
%     se ne non è multiplo di n1.

na1 = 100;                 % numero di medie (blocchi)
n1  = round(ne/na1) - 1;   % lunghezza di ciascun blocco [punti]
T1  = n1*dts;              % durata blocco [s]
df1 = 1/T1;                % risoluzione su ciascun blocco [Hz]
f1  = 0:df1:(n1-1)*df1;    % asse frequenze corrispondente

% Pre-allocazione (opzionale, utile per prestazioni su vettori grandi)
Auto_A  = zeros(n1, na1);  % autospettri accel per blocco
Auto_B  = zeros(n1, na1);  % autospettri mic per blocco
Cross_AB= zeros(n1, na1);  % cross-spettri per blocco

% A -> Accelerometer // B -> Microphone
for ii = 1:na1
    % TODO: compute FFTs for each subwindow and their conjugates
    A = fft(acce((ii-1)*n1+1:(ii*n1)))/(n1);
    A_c = conj(A);
    Auto_A(:,ii) = A_c.*A; % TODO: accelerometer auto-spectrum single window
    B = fft(mice((ii-1)*n1+1:(ii*n1)))/(n1); 
    B_c = conj(B);
    Auto_B(:,ii) = B_c.*B; % TODO: microphone auto-spectrum single window
    Cross_AB(:,ii) = A_c.*B; % TODO: cross-spectrum single window
end

S_A = mean(Auto_A(:,:),2);    % accelerometer auto-spectrum
S_B = mean(Auto_B(:,:),2);    % microphone auto-spectrum
S_AB = mean(Cross_AB(:,:),2); % cross-spectrum

% Coerenza: gamma^2 = |S_AB|^2 / (S_A * S_B), valore tra 0 e 1
Gamma = (abs(S_AB)).^2./(S_A.*S_B);

% Plot autospettri (moltiplicati per 2 se si intende monolato in potenza)
figure
    subplot(2,1,1)
    plot(f1, 2*real(S_A)); grid on
    xlabel('Frequency [Hz]'); ylabel('Auto-spectrum [(m/s^2)^2]');
    xlim([0 fs/2]); title('Accelerometer auto-spectrum');

    subplot(2,1,2)
    plot(f1, 2*real(S_B)); grid on
    xlabel('Frequency [Hz]'); ylabel('Auto-spectrum [V^2]');
    xlim([0 fs/2]); title('Microphone auto-spectrum');

% Plot cross-spettro reale/immaginario (informazione di fase/relazione)
figure
    subplot(2,1,1)
    plot(f1, 2*real(S_AB)); grid on
    xlabel('Frequency [Hz]'); ylabel('Cross-spectrum (Re) [(m/s^2)*(V)]');
    xlim([0 fs/2]); title('Extracted signals cross-spectrum (real part)');

    subplot(2,1,2)
    plot(f1, 2*imag(S_AB)); grid on
    xlabel('Frequency [Hz]'); ylabel('Cross-spectrum (Im) [(m/s^2)*(V)]');
    xlim([0 fs/2]); title('Extracted signals cross-spectrum (imag part)');

% Plot della coerenza (0..1): misura di linearità + SNR tra i due segnali
figure
    plot(f1, Gamma, 'LineWidth', 1.2); grid on
    xlabel('Frequency [Hz]'); ylabel('Coherence value')
    xlim([0 fs/2]); ylim([0 1]);
    title(['Signal ', num2str(na1),' averages coherence']);

%% NOTA BENE -------------------------------------------------------------
% - Se la finestra selezionata (ne) non è abbastanza lunga, la risoluzione
% in frequenza (df) risulta grossolana: conviene aumentare la durata.
% - Le medie (na1) migliorano la stima ma riducono la risoluzione dei blocchi
% (poiché n1 = round(ne/na1)-1). Bilanciare in base al contenuto spettrale.
% - Nessuna finestratura intra-blocco è applicata nella sezione 4: se i blocchi
% non contengono un numero intero di cicli, comparirà leakage. Per ridurlo,
% moltiplicare ciascun blocco per una finestra (Hann/Kaiser) prima della FFT.
% - In presenza di rumore, la coerenza si abbassa: picchi di Gamma vicino a 1
% indicano frequenze dove il legame tra i due segnali è lineare e forte.
