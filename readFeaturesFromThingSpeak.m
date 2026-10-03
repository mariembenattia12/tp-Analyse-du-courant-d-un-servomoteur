function readFeaturesFromThingSpeak(mdl, channelID, readKey)
persistent timestamp
persistent hplot

writeKey = 'MO4R4LM4B6STK7P7';

% a. fenêtre de lecture : 10 derniers jours au premier appel
if isempty(timestamp)
    timestamp = dateshift(datetime,"start","day",-10);
end

% b. lecture (timetable) depuis timestamp
T = thingSpeakRead(channelID,'ReadKey',readKey, ...
    'DateRange',[timestamp datetime], 'OutputFormat','timetable');
if isempty(T), return, end
T = T(max(1,height(T)-9):end,:);       % 10 derniers échantillons
timestamp = T.Timestamps(end) + seconds(1);   % évite de ré-injecter les mêmes points

% c. seuil et estimation du RUL
threshold = 10;
N = height(T);
estRUL = hours(zeros(1,N));
for i = 1:N
    update(mdl, T(i,:))
    estRUL(i) = predictRUL(mdl, threshold);
end
estRULAct = estRUL(N);

% d. tracé cumulatif
if isempty(hplot) || ~isvalid(hplot)
    figure
    hplot = plot(T.Timestamps, hours(estRUL), '-o');
    xlabel('Time'), ylabel('Estimated RUL (hours)'), title('Live RUL estimation')
    grid on
else
    hplot.XData = [hplot.XData, T.Timestamps'];
    hplot.YData = [hplot.YData, hours(estRUL)];
end
drawnow

% e. écriture dans le champ 6
thingSpeakWrite(channelID, hours(estRULAct), 'Fields', 6, 'WriteKey', writeKey);
end