%% éclipse 9
%  Le script parameterGeneratorEclipseIX.m  permet de fixer toute les
%  valeurs utilisées par le simulateur de circuit (course_sur_circuit.m) ou
%  de route (course_sur_route.m).
%
%  Toute les variables de ce fichier peuvent étre éditées de maniéres à
%  mieux représenter la voiture solaire ou le contexte de la compétition.
%
%  INSTRUCTIONS : Utilisez ce script à l'aide de la fonction run pour
%  inclure son contenu dans le workspace courant
%  ex : run('parameterGeneratorEclipseIX.m');
%
%  Note : l'utilisation de structures est encouragée dans ce fichier pour
%  alléger le nombre d'arguments dans le simulateur
%
%  IMPORTANT : TOUJOURS INDIQUER LES UNITéS UTILISéS POUR CHAQUE VARIABLE !!!
%
%  Auteur : Julien Longchamp
%  Date de création : 07-07-2016
%  Derniére modification : 17-01-2017 (JL) Changement de nom de variable : contraintes -> strategy
%%

% ANCIENNE ARCHITECTURE
% % Ajout du chemin vers les outils nécessaires au fonctionnement du simulateur
% addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils');
% addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SolarAzEl');


%% Importation des modéles statiques
% Importation des courbes de décharge des cellules NCR18650BF
%cellModel = load('Eclipse9_cells_discharge.mat');
cellModel = load('Data/ECLIPSE9_cells_discharge.mat'); % Octave

% IMPORTANT DE CHOISIR LES BONS COEFFICIENTS POUR LE CYCLE DU SOLEIL !
%% Charge les coefficients de la courbe de l'irradiance du 41e paralléle Nord.  **** Voir le fichier TESTsolarradiation.m pour plus de détails. ****
% load('SolarIrradianceLat41N.mat', 'irrandiance_coef');
% Charge les coefficients du cycle du soleil pour la FSGP2016
%load('SoleilFSGPcoef.mat');
load('Data/FSGP2016_sun_coef.mat'); % Octave

%% Contraintes du parcours
strategy.vitesse_min = 50/3.6;   % m/s (60 km/h)
strategy.vitesse_moy = 70/3.6;   % m/s (80 km/h) *** VITESSE CIBLE ***
strategy.vitesse_max = 120/3.5;  % m/s (105 km/h)
strategy.vitesse_ini = 0;        % m/s
strategy.accel_nom = 0.1;        % m/s^2
strategy.accel_max = 1;          % m/s^2
strategy.decel_nom = -0.03;      % m/s^2
strategy.SoC_ini = 0.99;            % Initial State of Charge (%)
strategy.SoC_min = 0.25;         % Final State of Charge (%)

%% Paramétres du véhicule éclipse 9
eclipse9.masse_totale = 300;     % kg % éCLIPSE 9 : 220 kg sans pilote + 80 kg pilote avec ballaste
eclipse9.aire_frontale = 1.25;   % m^2
eclipse9.coef_trainee = 0.13; % Calculé le 30 juillet 2016 ASC jour 1  %0.125;%0.135;   % coefficient de trainée aérodynamique       ********** é VéRIFIER **********
%eclipse9.coef_trainee = 0.25;      % éCLIPSE 9 SANS COQUE
eclipse9.frottement = 43;       % N
eclipse9.rayon_roue = 0.271;    % m                                           ********** à VéRIFIER **********
eclipse9.surface_solaire = 5.994;    % m^2
eclipse9.nb_roue = 4;            % Nombre de roues
eclipse9.largeur_pneu = 0.03;    % m                                 ********** à VéRIFIER **********
eclipse9.hauteur_roue = 2*eclipse9.rayon_roue;     % m               ********** à VéRIFIER **********
eclipse9.nb_moteur = 2;
eclipse9.vitesse_nom = 111;    % rad/s (Pour un moteur)
eclipse9.couple_nom = 16.2;    % Nm    (Pour un moteur)
eclipse9.couple_max = 42;      % Nm    (Pour un moteur)
eclipse9.puissance_max = 1800; % W     (Pour un moteur)

%% Constantes physiques 
constantes.const_grav = 9.81;      % m/s^2
constantes.constante_universelle_gaz_parfaits = 8.3144621; % J/(k*mol)Constante universelle des gaz parfaits
constantes.zero_absolu = 273.15; % écart entre zéro degré Celcius et degrés Kelvins
constantes.masse_molaire_air = 28.965338/1000; % kg/mol
% CONSTANTES OBSOLéTES
% constantes.tempAmbiant = 273.15+20;  % Température ambiante (Kelvin)
% constantes.absolutePressure = 101.325 * 1000; % Pa
% constantes.specificAirConstant = 287.058; % J/(kg*K)
% constantes.mv_air = constantes.absolutePressure/(constantes.specificAirConstant*constantes.tempAmbiant);     % kg/m^3         % TODO : Transformer en équation en fonction de la pression atmosphérique et de la température
% constantes.vitesse_vent = 20/3.6; % m/s
% constantes.direction_vent = 220; % degrés
% constantes.irrandiance_coef = irrandiance_coef; % Coefficients du polinôme représentant la densité de puissance incidente du soleil
% constantes.densite_de_puissance_incidente = 800; % W/m^2                ******* TODO : à changer *******

%% Données météo
% Les données météos peuvent étre divisée en vecteurs [1xn] pour séparer l'information en n tranches de journées
% ex. meteo.temperature = [20 28] -> 20deg de 7hjusqu'à midi et 28deg de midi jusqu'à 20h
meteo.vitesse_vent = [0 0]; % km/h
meteo.direction_vent = [0 0]; % degrés 
meteo.couverture_ciel = [1 1]; % Pourcentage du ciel dégagé (Multiplie la puissance calculée des panneaux)
meteo.pression_atmospherique = [101.9 101.9]; % kPa
meteo.temperature = [30 30]; % Degré celcius
meteo.mv_air = 1000*meteo.pression_atmospherique*constantes.masse_molaire_air ./ (constantes.constante_universelle_gaz_parfaits * (constantes.zero_absolu + meteo.temperature)); % kg/m^3
meteo.sun_cycle_coef = sun_coef;

%% Réglements de la ASC 2016 rev. B
reglement.impound_out = 7/24; % Batterie disponible à partir de 7h00
reglement.impound_in = 20/24; % Batterie non-disponible à partir de 20h00
reglement.fsgp_fin_recharge_matin = 9/24; % Fin de la recharge du matin à 8h45
reglement.heure_depart = 9/24; % Départ à 9h00     (10h la premiére journée de la FSGP) (Actuellement à 13h15)
reglement.heure_arret = 18/24; % Arrét à 18h00      (17h les deux derniéres journées de la FSGP)
% reglement.checkpoint = [350.762]; % km (Distance avant chaque checkpoint) **** éTAPE 1 UNIQUEMENT ****

%% Valeurs initiales au départ
etat_course.SoC_start = strategy.SoC_ini; % (%)
etat_course.nbLap = 0;
etat_course.vitesse_ini = 0; % m/s
etat_course.heure_depart = datenum([2016,08,5,reglement.heure_depart*24,0,0]); % Format de l'heure : [yyyy, mm, jj, hh, mm, ss]
