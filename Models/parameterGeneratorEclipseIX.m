%% �clipse 9
%  Le script parameterGeneratorEclipseIX.m  permet de fixer toute les
%  valeurs utilis�es par le simulateur de circuit (course_sur_circuit.m) ou
%  de route (course_sur_route.m).
%
%  Toute les variables de ce fichier peuvent �tre �dit�es de mani�res �
%  mieux repr�senter la voiture solaire ou le contexte de la comp�tition.
%
%  INSTRUCTIONS : Utilisez ce script � l'aide de la fonction run pour
%  inclure son contenu dans le workspace courant
%  ex : run('parameterGeneratorEclipseIX.m');
%
%  Note : l'utilisation de structures est encourag�e dans ce fichier pour
%  all�ger le nombre d'arguments dans le simulateur
%
%  IMPORTANT : TOUJOURS INDIQUER LES UNIT�S UTILIS�S POUR CHAQUE VARIABLE !!!
%
%  Auteur : Julien Longchamp
%  Date de cr�ation : 07-07-2016
%  Derni�re modification : 17-01-2017 (JL) Changement de nom de variable : contraintes -> strategy
%%

% ANCIENNE ARCHITECTURE
% % Ajout du chemin vers les outils n�cessaires au fonctionnement du simulateur
% addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils');
% addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SolarAzEl');


%% Importation des mod�les statiques
% Importation des courbes de d�charge des cellules NCR18650BF
%cellModel = load('Eclipse9_cells_discharge.mat');
cellModel = load('Data/Eclipse9_cells_discharge.mat'); % Octave

% IMPORTANT DE CHOISIR LES BONS COEFFICIENTS POUR LE CYCLE DU SOLEIL !
%% Charge les coefficients de la courbe de l'irradiance du 41e parall�le Nord.  **** Voir le fichier TESTsolarradiation.m pour plus de d�tails. ****
% load('SolarIrradianceLat41N.mat', 'irrandiance_coef');
% Charge les coefficients du cycle du soleil pour la FSGP2016
%load('SoleilFSGPcoef.mat');
load('Data/SoleilFSGPcoef.mat'); % Octave

%% Contraintes du parcours
strategy.vitesse_min = 50/3.6;   % m/s (60 km/h)
strategy.vitesse_moy = 65/3.6;   % m/s (80 km/h) *** VITESSE CIBLE ***
strategy.vitesse_max = 120/3.5;  % m/s (105 km/h)
strategy.vitesse_ini = 0;        % m/s
strategy.accel_nom = 0.1;        % m/s^2
strategy.accel_max = 1;          % m/s^2
strategy.decel_nom = -0.03;      % m/s^2
strategy.SoC_ini = 0.99;            % Initial State of Charge (%)
strategy.SoC_min = 0.30;         % Final State of Charge (%)

%% Param�tres du v�hicule �clipse 9
eclipse9.masse_totale = 300;     % kg % �CLIPSE 9 : 220 kg sans pilote, pilote avec ballastes : 80 kg
eclipse9.aire_frontale = 1.25;   % m^2
eclipse9.coef_trainee = 0.13; % Calcul� le 30 juillet 2016 ASC jour 1  %0.125;%0.135;   % coefficient de train�e a�rodynamique       ********** � V�RIFIER **********
%eclipse9.coef_trainee = 0.25;      % �CLIPSE 9 SANS COQUE
eclipse9.frottement = 43;       % N
eclipse9.rayon_roue = 0.271;    % m                                           ********** � V�RIFIER **********
eclipse9.surface_solaire = 5.994;    % m^2
eclipse9.nb_roue = 4;            % Nombre de roues
eclipse9.largeur_pneu = 0.03;    % m                                 ********** � V�RIFIER **********
eclipse9.hauteur_roue = 2*eclipse9.rayon_roue;     % m               ********** � V�RIFIER **********
eclipse9.nb_moteur = 2;
eclipse9.vitesse_nom = 111;    % rad/s (Pour un moteur)
eclipse9.couple_nom = 16.2;    % Nm    (Pour un moteur)
eclipse9.couple_max = 42;      % Nm    (Pour un moteur)
eclipse9.puissance_max = 1800; % W     (Pour un moteur)

%% Constantes physiques 
constantes.const_grav = 9.81;      % m/s^2
constantes.constante_universelle_gaz_parfaits = 8.3144621; % J/(k*mol)Constante universelle des gaz parfaits
constantes.zero_absolu = 273.15; % �cart entre z�ro degr� Celcius et degr�s Kelvins
constantes.masse_molaire_air = 28.965338/1000; % kg/mol
% CONSTANTES OBSOL�TES
% constantes.tempAmbiant = 273.15+20;  % Temp�rature ambiante (Kelvin)
% constantes.absolutePressure = 101.325 * 1000; % Pa
% constantes.specificAirConstant = 287.058; % J/(kg*K)
% constantes.mv_air = constantes.absolutePressure/(constantes.specificAirConstant*constantes.tempAmbiant);     % kg/m^3         % TODO : Transformer en �quation en fonction de la pression atmosph�rique et de la temp�rature
% constantes.vitesse_vent = 20/3.6; % m/s
% constantes.direction_vent = 220; % degr�s
% constantes.irrandiance_coef = irrandiance_coef; % Coefficients du polin�me repr�sentant la densit� de puissance incidente du soleil
% constantes.densite_de_puissance_incidente = 800; % W/m^2                ******* TODO : � changer *******

%% Donn�es m�t�o
% Les donn�es m�t�os peuvent �tre divis�e en vecteurs [1xn] pour s�parer l'information en n tranches de journ�es
% ex. meteo.temperature = [20 28] -> 20�de 7hjusqu'� midi et 28�de midi jusqu'� 20h
meteo.vitesse_vent = [0 0]; % km/h
meteo.direction_vent = [0 0]; % degr�s 
meteo.couverture_ciel = [1 1]; % Pourcentage du ciel d�gag� (Multiplie la puissance calcul�e des panneaux)
meteo.pression_atmospherique = [101.9 101.9]; % kPa
meteo.temperature = [30 30]; % Degr� celcius
meteo.mv_air = 1000*meteo.pression_atmospherique*constantes.masse_molaire_air ./ (constantes.constante_universelle_gaz_parfaits * (constantes.zero_absolu + meteo.temperature)); % kg/m^3
meteo.sun_cycle_coef = sun_coef;

%% R�glements de la ASC 2016 rev. B
reglement.impound_out = 7/24; % Batterie disponible � partir de 7h00
reglement.impound_in = 20/24; % Batterie non-disponible � partir de 20h00
reglement.fsgp_fin_recharge_matin = 9/24; % Fin de la recharge du matin � 8h45
reglement.heure_depart = 9/24; % D�part � 9h00     (10h la premi�re journ�e de la FSGP) (Actuellement � 13h15)
reglement.heure_arret = 18/24; % Arr�t � 18h00      (17h les deux derni�res journ�es de la FSGP)
% reglement.checkpoint = [350.762]; % km (Distance avant chaque checkpoint) **** �TAPE 1 UNIQUEMENT ****

%% Valeurs initiales au d�part
etat_course.SoC_start = strategy.SoC_ini; % (%)
etat_course.nbLap = 0;
etat_course.vitesse_ini = 0; % m/s
etat_course.heure_depart = datenum([2016,08,5,reglement.heure_depart*24,0,0]); % Format de l'heure : [yyyy, mm, jj, hh, mm, ss]
