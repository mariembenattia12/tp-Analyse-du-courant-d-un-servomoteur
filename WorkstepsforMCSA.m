load('mcsaData.mat','servoData')
servoData                         % structure
servoData.healthyData             % cell array 10x1
servoData.faultyData              % cell array 10x1
head(servoData.healthyData{1,1})
t  = servoData.healthyData{1,1}.Time;
fs = 1/seconds(t(2)-t(1))        % attendu : 1500 Hz (Arduino à 1.5 kHz)

%% Premier timetable de chaque jeu (sain et défectueux)
healthyData = servoData.healthyData{1,1};
faultyData  = servoData.faultyData{1,1};

healthyCurrent = healthyData.Signal;   % courant en mA
faultyCurrent  = faultyData.Signal;
healthyTacho   = healthyData.Pulse;    % impulsions tachymètre (8 / tour)
faultyTacho    = faultyData.Pulse;
tHealthy = healthyData.Time;
tFaulty  = faultyData.Time;

%% Tracé
figure
ax1 = subplot(221);
plot(tHealthy,healthyCurrent)
title('Current Signal - Healthy Gears')
ylabel('Current (mA)')

ax2 = subplot(222);
plot(tFaulty,faultyCurrent)
title('Current Signal - Faulty Gears')
ylabel('Current (mA)')

ax3 = subplot(223);
plot(tHealthy,healthyTacho)
title('Tachometer Pulse - Healthy Gears')
ylabel('Pulses, 8/rev')

ax4 = subplot(224);
plot(tFaulty,faultyTacho)
title('Tachometer Pulse - Faulty Gears')
ylabel('Pulses, 8/rev')

linkaxes([ax1,ax2,ax3,ax4],'x');   % zoom synchronisé sur les 4 graphes
ax1.XLim = seconds([0 2]);          % affiche les 2 premières secondes

fs = 1500;

% Calcul de la vitesse (le signal Pulse peut être de type numérique)
[rpmHealthy1,tHealthy1,tpHealthy1] = tachorpm(healthyTacho,fs,'PulsesPerRev',8);
[rpmFaulty1, tFaulty1, tpFaulty1 ] = tachorpm(faultyTacho, fs,'PulsesPerRev',8);

% Conversion des temps en secondes (double) si ce sont des durations
if isduration(tpHealthy1), tpH = seconds(tpHealthy1); else, tpH = tpHealthy1; end
if isduration(tHealthy1),  tH  = seconds(tHealthy1);  else, tH  = tHealthy1;  end
if isduration(tpFaulty1),  tpF = seconds(tpFaulty1);  else, tpF = tpFaulty1;  end
if isduration(tFaulty1),   tF  = seconds(tFaulty1);   else, tF  = tFaulty1;   end

% Axe temps du signal tacho en secondes
tSecH = seconds(tHealthy);
tSecF = seconds(tFaulty);

%% Figure sain
figure
subplot(211)
plot(tSecH,healthyTacho), hold on
plot(tpH, interp1(tSecH,double(healthyTacho),tpH),'ro')   % impulsions détectées
title('Tacho sain + impulsions détectées'), xlabel('Time (s)')
subplot(212)
plot(tH,rpmHealthy1), ylabel('rpm'), xlabel('Time (s)')
title('Vitesse - sain')

%% Figure défectueux
figure
subplot(211)
plot(tSecF,faultyTacho), hold on
plot(tpF, interp1(tSecF,double(faultyTacho),tpF),'ro')
title('Tacho défectueux + impulsions détectées'), xlabel('Time (s)')
subplot(212)
plot(tF,rpmFaulty1), ylabel('rpm'), xlabel('Time (s)')
title('Vitesse - défectueux')


rpmHealthy = mean(rpmHealthy1,'omitnan')
rpmFaulty  = mean(rpmFaulty1,'omitnan')

% Nombre de dents des engrenages et des pignons
G4 = 41; G3 = 35; G2 = 50; G1 = 62;
P4 = 16; P3 = 10; P2 = 10; P1 = 10;

rpm = rpmHealthy;

FS5 = mean(rpm)/60;      % vitesse de l'arbre de sortie (Hz)
FS4 = G4/P4*FS5;
FS3 = G3/P3*FS4;
FS2 = G2/P2*FS3;
FS1 = G1/P1*FS2;

FS = [FS1, FS2, FS3, FS4, FS5]

[FB1,info1] = faultBands(FS1,1:2,FS2,0:1);  % FS1, 2 harmoniques, bandes latérales 0:1 de FS2
[FB2,info2] = faultBands(FS2,1:2,FS3,0:1);
[FB3,info3] = faultBands(FS3,1:2);
[FB4,info4] = faultBands(FS4,1:2);


%% Q7 : spectre de puissance sain et défectueux
fs = 1500;

figure
pspectrum(healthyCurrent,fs,'FrequencyResolution',0.5)
hold on
pspectrum(faultyCurrent,fs,'FrequencyResolution',0.5)
hold on

info1.Labels = regexprep(info1.Labels,'F0','FS1');
info1.Labels = regexprep(info1.Labels,'F1','FS2');
helperPlotXLines(info1,[0.5 0.5 0.5])

info2.Labels = regexprep(info2.Labels,'F0','FS2');
info2.Labels = regexprep(info2.Labels,'F1','FS3');
helperPlotXLines(info2,[0.5 0.5 0.5])

info3.Labels = regexprep(info3.Labels,'F0','FS3');
helperPlotXLines(info3,[0.5 0.5 0.5])

info4.Labels = regexprep(info4.Labels,'F0','FS4');
helperPlotXLines(info4,[0.5 0.5 0.5])

legend('Healthy Data','Faulty Data','Location','South')
hold off
xlim([25 50])    % FS2 et ses bandes latérales (FS2 ± FS3)
xlim([0 20])     % FS3, 2FS3, FS4, 2FS4
xlim([210 255])  % FS1 et ses bandes latérales
rpmHealthy, rpmFaulty
FS1_faulty = (62/10)*(50/10)*(35/10)*(41/16)*rpmFaulty/60

[psdHealthy,fHealthy] = pspectrum(healthyCurrent,fs,'FrequencyResolution',0.5);
[psFaulty, fFaulty ]  = pspectrum(faultyCurrent, fs,'FrequencyResolution',0.5);

FB = [FB1; FB2; FB3; FB4];
spectralMetricsHealthy = faultBandMetrics(psdHealthy,fHealthy,FB);
spectralMetricsFaulty  = faultBandMetrics(psFaulty, fFaulty, FB);
[spectralMetricsHealthy; spectralMetricsFaulty]   % comparaison

load('mcsaData.mat','servoData')
fs = 1500;
allT = table();
for k = 1:20
    if k<=10, D = servoData.healthyData{k,1}; lab = "Healthy";
    else,     D = servoData.faultyData{k-10,1}; lab = "Faulty"; end
    m = computeMetrics(D, fs);        % fonction locale ci-dessous
    m.Condition = lab;
    allT = [allT; m]; %#ok<AGROW>
end

figure
gscatter(allT.PeakAmplitude2, allT.PeakAmplitude5, allT.Condition)
xlabel('PeakAmplitude2'), ylabel('PeakAmplitude5'), grid on
title('Healthy vs Faulty')

figure
gscatter(allT.TotalBandPower, allT.PeakAmplitude2, allT.Condition)

classificationLearner   % choisir allT, réponse = Condition

function m = computeMetrics(D, fs)
rpm = mean(tachorpm(D.Pulse,fs,'PulsesPerRev',8),'omitnan');
G4=41; G3=35; G2=50; G1=62; P4=16; P3=10; P2=10; P1=10;
FS5 = rpm/60;  FS4 = G4/P4*FS5; FS3 = G3/P3*FS4;
FS2 = G2/P2*FS3; FS1 = G1/P1*FS2;
FB1 = faultBands(FS1,1:2,FS2,0:1);
FB2 = faultBands(FS2,1:2,FS3,0:1);
FB3 = faultBands(FS3,1:2);
FB4 = faultBands(FS4,1:2);
[ps,f] = pspectrum(D.Signal,fs,'FrequencyResolution',0.5);
m = faultBandMetrics(ps,f,[FB1;FB2;FB3;FB4]);
end

