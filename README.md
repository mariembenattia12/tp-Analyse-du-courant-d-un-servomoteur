# TP3 : analyse du courant d'un servomoteur (détection de défauts d'engrenages et estimation du RUL)

TP du cours *Algorithmics for Edge Processing in IoT* (SUP'COM).
Servomoteur Futaba S3003 : détection de défauts sur les engrenages G2 et G3 par analyse de signature du courant moteur (MCSA), puis estimation en temps réel de la durée de vie résiduelle (RUL) via ThingSpeak et MATLAB.

## Contenu

| Fichier | Rôle |
|---|---|
| `WorkstepsforMCSA.m` | Partie 1 : chargement, vitesses, fréquences d'intérêt, bandes de défaut, spectres, métriques, nuage de points |
| `startSending.m` | Timer (60 s) qui envoie les caractéristiques vers ThingSpeak |
| `sendSyntheticFeaturesToThingSpeak.m` | Calcule les caractéristiques d'un jeu sain tiré au hasard et les écrit dans le canal |
| `startRULEstimation.m` | Construit le modèle `exponentialDegradationModel` et lance le timer de lecture |
| `readFeaturesFromThingSpeak.m` | Lit le canal, met à jour le modèle (`update`), estime le RUL (`predictRUL`), trace et écrit le champ 6 |
| `rul_alert_analysis.m` | MATLAB Analysis ThingSpeak : alerte (statut + e-mail) si RUL < 8 h |
| `config_example.m` | Modèle de fichier de configuration (clés API) |
| `figures/` | Résultats obtenus |

## Prérequis

- MATLAB (ou MATLAB Online) avec la **Predictive Maintenance Toolbox**
- Un compte ThingSpeak et un canal à 6 champs :
  PeakAmplitude2, PeakAmplitude5, TotalBandPower, courant moyen, vitesse moyenne (tr/min), RUL
- Le fichier de données `mcsaData.mat` et la fonction `helperPlotXLines.m`, **fournis par l'enseignant** (non inclus dans ce dépôt)

## Configuration

1. Copiez `config_example.m` sous le nom `config.m` et renseignez votre Channel ID et vos clés API.
2. `config.m` est ignoré par Git : vos clés ne sont pas publiées.
3. Placez `mcsaData.mat` et `helperPlotXLines.m` dans le même dossier que les scripts.

## Utilisation

```matlab
WorkstepsforMCSA          % Partie 1 : analyse MCSA
startSending              % envoi des caractéristiques toutes les 60 s
% attendre quelques minutes pour que le canal contienne des données
startRULEstimation        % estimation du RUL toutes les 60 s
delete(timerfindall)      % arrêt des timers
```

Pour l'alerte : créer une MATLAB Analysis avec `rul_alert_analysis.m`, puis un TimeControl (toutes les 10 minutes).

## Résultats principaux

- Vitesses moyennes : 49,85 tr/min (sain) et 49,53 tr/min (défectueux), pour 50 tr/min théoriques.
- Fréquences d'intérêt : FS1 = 231,0 Hz, FS2 = 37,3 Hz, FS3 = 7,45 Hz, FS4 = 2,13 Hz, FS5 = 0,83 Hz.
- `TotalBandPower` : environ 4 (sain) contre environ 10 (défectueux) sur le couple analysé ; elle sépare les 20 acquisitions.
- Le RUL estimé est instable : les données envoyées proviennent de jeux sains choisis au hasard, sans dégradation réelle.

## Figures

Voir le dossier [`figures/`](figures/).

## Remarque

Projet pédagogique. Données et énoncé du TP : propriété de l'enseignant (F. Rouissi, SUP'COM).
