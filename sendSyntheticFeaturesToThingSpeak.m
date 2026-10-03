function sendSyntheticFeaturesToThingSpeak()
% a. chargement + jeu aléatoire
load('mcsaData.mat','servoData');
ind = randi(10,1,1);
TestData    = servoData.healthyData{ind,1};
TestCurrent = TestData.Signal;
TestTacho   = TestData.Pulse;
Fs = 1500;

% b. vitesse moyenne
rpm = mean(tachorpm(TestTacho,Fs,'PulsesPerRev',8),'omitnan');

% c. fréquences d'intérêt et bandes
G4=41; G3=35; G2=50; G1=62; P4=16; P3=10; P2=10; P1=10;
FS5 = rpm/60;  FS4 = G4/P4*FS5;  FS3 = G3/P3*FS4;
FS2 = G2/P2*FS3;  FS1 = G1/P1*FS2;
FB1 = faultBands(FS1,1:2,FS2,0:1);
FB2 = faultBands(FS2,1:2,FS3,0:1);
FB3 = faultBands(FS3,1:2);
FB4 = faultBands(FS4,1:2);
FB  = [FB1; FB2; FB3; FB4];

% d. PSD
mC = TestCurrent;
[ps1,f1] = pspectrum(mC,Fs,'FrequencyResolution',0.5);

% e. 49 métriques
spectralMetrics = faultBandMetrics(ps1,f1,FB);

% f. vecteur de features
features = [spectralMetrics.PeakAmplitude2, ...
    spectralMetrics.PeakAmplitude5, ...
    spectralMetrics.TotalBandPower, ...
    mean(mC), rpm];

% g. envoi
channelID = 3518312;            % <-- votre Channel ID
writeKey  = 'MO4R4LM4B6STK7P7';  % <-- votre Write key
fields = 1:numel(features);
thingSpeakWrite(channelID, features, 'Fields', fields, 'WriteKey', writeKey);
end