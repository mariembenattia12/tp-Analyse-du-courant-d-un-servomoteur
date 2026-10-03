%% Q7 : construction du modèle de dégradation exponentielle + lecture ThingSpeak
channelID = 3518312;               % <-- votre Channel ID
readKey   = 'Z457LMODUQUFH4FB';      % <-- votre Read API key

% Lecture des données les plus récentes depuis ThingSpeak
T = thingSpeakRead(channelID,'ReadKey',readKey,'OutputFormat','timetable');

% Modèle de dégradation exponentielle, indice de santé = Total Band Power (champ 3)
mdl = exponentialDegradationModel( ...
    'Theta', 1, 'ThetaVariance', 100, ...      % prior sur θ (arbitraire)
    'Beta', 1,  'BetaVariance', 100, ...       % prior sur β (arbitraire)
    'NoiseVariance', 0.01, ...                 % variance du bruit
    'LifeTimeVariable', T.Properties.DimensionNames{1}, ...   % "Timestamps"
    'DataVariables', T.Properties.VariableNames{3}, ...       % 3e colonne = TotalBandPower
    'LifeTimeUnit', "hours");

% Timer : lecture et mise à jour du RUL toutes les 60 s
tmr2 = timer('ExecutionMode','fixedSpacing','Period',60);
tmr2.TimerFcn = @(~,~) readFeaturesFromThingSpeak(mdl,channelID,readKey);
tmr2.start();