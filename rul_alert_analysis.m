% rul_alert_analysis.m
% À copier dans une MATLAB Analysis ThingSpeak (nom : RUL_Alert).
% Déclenchée toutes les 10 minutes par un TimeControl (ou par une app React).
% Sur ThingSpeak, remplacez les 4 valeurs ci-dessous par les vôtres
% (ne publiez jamais ce fichier avec les vraies clés).

channelID = 0000000;
readKey   = 'VOTRE_READ_API_KEY';
writeKey  = 'VOTRE_WRITE_API_KEY';
alertKey  = 'VOTRE_ALERTS_API_KEY';

% Dernière valeur de RUL (champ 6)
rul = thingSpeakRead(channelID,'Fields',6,'NumPoints',1,'ReadKey',readKey);

if ~isempty(rul) && ~isnan(rul) && rul < 8
    msg = sprintf('ALERT: servo gear train failure imminent, RUL = %.2f h', rul);

    % 1. Message de statut dans le canal
    thingSpeakWrite(channelID, rul, 'Fields', 6, 'Status', msg, 'WriteKey', writeKey);

    % 2. E-mail automatique
    alertUrl = "https://api.thingspeak.com/alerts/send";
    opts = weboptions("HeaderFields", ["ThingSpeak-Alerts-API-Key", alertKey]);
    webwrite(alertUrl, "subject", "Servo RUL alert", "body", msg, opts);
end
