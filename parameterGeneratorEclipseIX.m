%% Éclipse 9
%  Le script parameterGeneratorEclipseIX.m  permet de fixer toute les
%  valeurs utilisées par le simulateur de circuit (course_sur_circuit.m) ou
%  de route (course_sur_route.m).
%
%  Toute les variables de ce fichier peuvent être éditées de manières à
%  mieux représenter la voiture solaire ou le contexte de la compétition.
%
%  INSTRUCTIONS : Utilisez ce script à l'aide de la fonction run pour
%  inclure son contenu dans le workspace courant
%  ex : run('parameterGeneratorEclipseIX.m');
%
%  Note1 : l'utilisation de structures est encouragée dans ce fichier uniquement
%
%  IMPORTANT : TOUJOURS INDIQUER LES UNITÉS UTILISÉS POUR CHAQUE VARIABLE !!!
%
%  Auteur : Julien Longchamp
%  Date de création : 07-07-2016
%  Dernière modification :
%%

% Ajout du chemin vers les outils nécessaires au fonctionnement du simulateur
addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils');
addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SolarAzEl');


%% Importation des modèles statiques
% Importation des courbes de décharge des cellules NCR18650BF
cellModel = load('Eclipse9_cells_discharge.mat');
% Charge les coefficients de la courbe de l'irradiance du 41e parallèle Nord.  **** Voir le fichier TESTsolarradiation.m pour plus de détails. ****
% load('SolarIrradianceLat41N.mat', 'irrandiance_coef');
% Charge les coefficients du cycle du soleil pour la FSGP2016
load('SoleilFSGPcoef.mat');

%% Contraintes du parcours
contraintes.vitesse_min = 20/3.6;   % m/s (60 km/h)
contraintes.vitesse_moy = 30/3.6;   % m/s (80 km/h) *** VITESSE CIBLE ***
contraintes.vitesse_max = 120/3.5;  % m/s (105 km/h)
contraintes.vitesse_ini = 0;        % m/s
contraintes.accel_nom = 0.1;        % m/s^2
contraintes.accel_max = 1;          % m/s^2
contraintes.decel_nom = -0.03;      % m/s^2
contraintes.SoC_ini = 0.36;            % Initial State of Charge (%)
contraintes.SoC_min = 0.30;         % Final State of Charge (%)

%% Paramètres du véhicule Éclipse 9
eclipse9.masse_totale = 300;     % kg % ÉCLIPSE 9 SANS COQUE
eclipse9.aire_frontale = 1.25;   % m^2
eclipse9.coef_trainee = 0.13; % Calculé le 30 juillet 2016 ASC jour 1  %0.125;%0.135;   % coefficient de trainée aérodynamique       ********** À VÉRIFIER **********
%eclipse9.coef_trainee = 0.25;      % ÉCLIPSE 9 SANS COQUE
eclipse9.frottement = 43;       % N
eclipse9.rayon_roue = 0.271;    % m                                           ********** À VÉRIFIER **********
eclipse9.surface_solaire = 5.994;    % m^2
eclipse9.nb_roue = 4;            % Nombre de roues
eclipse9.largeur_pneu = 0.03;    % m                                 ********** À VÉRIFIER **********
eclipse9.hauteur_roue = 2*eclipse9.rayon_roue;     % m               ********** À VÉRIFIER **********
eclipse9.nb_moteur = 2;
eclipse9.vitesse_nom = 111;    % rad/s (Pour un moteur)
eclipse9.couple_nom = 16.2;    % Nm    (Pour un moteur)
eclipse9.couple_max = 42;      % Nm    (Pour un moteur)
eclipse9.puissance_max = 1800; % W     (Pour un moteur)

%% Constantes physiques     % TODO : À remplacer par des vecteurs fournies par le module Eagle Tree
constantes.const_grav = 9.81;      % m/s^2
% constantes.tempAmbiant = 273.15+20;  % Température ambiante (Kelvin)
% constantes.absolutePressure = 101.325 * 1000; % Pa
% constantes.specificAirConstant = 287.058; % J/(kg*K)
% constantes.mv_air = constantes.absolutePressure/(constantes.specificAirConstant*constantes.tempAmbiant);     % kg/m^3         % TODO : Transformer en équation en fonction de la pression atmosphérique et de la température
% constantes.vitesse_vent = 20/3.6; % m/s
% constantes.direction_vent = 220; % degrés
% constantes.irrandiance_coef = irrandiance_coef; % Coefficients du polinôme représentant la densité de puissance incidente du soleil
% constantes.densite_de_puissance_incidente = 800; % W/m^2                ******* TODO : À changer *******
constantes.constante_universelle_gaz_parfaits = 8.3144621; % J/(k*mol)Constante universelle des gaz parfaits
constantes.zero_absolu = 273.15; % Écart entre zéro degré Celcius et degrés Kelvins
constantes.masse_molaire_air = 28.965338/1000; % kg/mol

%% Données météo
% Les données météos peuvent être divisée en vecteurs [1xn] pour séparer l'information en n tranches de journées
% ex. meteo.temperature = [20 28] -> 20°de 7hjusqu'à midi et 28°de midi jusqu'à 20h
meteo.vitesse_vent = [9.25 9.25]; % km/h
meteo.direction_vent = [0 0]; % degrés 
meteo.couverture_ciel = [1.5/6 1.5/6]; % Pourcentage du ciel dégagé (Multiplie la puissance calculée des panneaux)
meteo.pression_atmospherique = [101.9 101.9]; % kPa
meteo.temperature = [34 34]; % Degré celcius
meteo.mv_air = 1000*meteo.pression_atmospherique*constantes.masse_molaire_air ./ (constantes.constante_universelle_gaz_parfaits * (constantes.zero_absolu + meteo.temperature)); % kg/m^3
meteo.sun_cycle_coef = sun_coef;

%% Règlements de la ASC 2016 rev. B
reglement.impound_out = 7/24; % Batterie disponible à partir de 7h00
reglement.impound_in = 20/24; % Batterie non-disponible à partir de 20h00
reglement.fsgp_fin_recharge_matin = 9/24; % Fin de la recharge du matin à 8h45
reglement.heure_depart = 13.25/24; % Départ à 9h00     (10h la première journée de la FSGP)
reglement.heure_arret = 18/24; % Arrêt à 18h00      (17h les deux dernières journées de la FSGP)
% reglement.checkpoint = [350.762]; % km (Distance avant chaque checkpoint) **** ÉTAPE 1 UNIQUEMENT ****

%% Valeurs initiales au départ
etat_course.SoC_start = contraintes.SoC_ini;
etat_course.nbLap = 0;
etat_course.vitesse_ini = 0; % m/s
etat_course.heure_depart = datenum([2016,08,5,reglement.heure_depart*24,0,0]); % Format de l'heure : [yyyy, mm, jj, hh, mm, ss]
