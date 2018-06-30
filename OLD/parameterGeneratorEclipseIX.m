%% Eclipse 9
%  Le script parameterGeneratorEclipseIX.m  permet de fixer toute les
%  valeurs utilisees par le simulateur de circuit (course_sur_circuit.m) ou
%  de route (course_sur_route.m).
%
%  Toute les variables de ce fichier peuvent etre editees de manieres a
%  mieux representer la voiture solaire ou le contexte de la competition.
%
%  INSTRUCTIONS : Utilisez ce script a l'aide de la fonction run pour
%  inclure son contenu dans le workspace courant
%  ex : run('parameterGeneratorEclipseIX.m');
%
%  Note : l'utilisation de structures est encouragee dans ce fichier pour
%  alleger le nombre d'arguments dans le simulateur
%
%  IMPORTANT : TOUJOURS INDIQUER LES UNITES UTILISES POUR CHAQUE VARIABLE !!!
%
%  Auteur : Julien Longchamp
%  Date de creation : 07-07-2016
%  Derniere modification : 17-01-2017 (JL) Changement de nom de variable : contraintes -> strategy
%%

% ANCIENNE ARCHITECTURE
% % Ajout du chemin vers les outils n�cessaires au fonctionnement du simulateur
% addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils');
% addpath('C:\Users\Strategy\Documents\MATLAB\StrategyEclipseIX\StrategieCourseASC2016\Outils\SolarAzEl');


%% Importation des modeles statiques
% Importation des courbes de decharge des cellules NCR18650BF
%cellModel = load('Eclipse9_cells_discharge.mat');
cellModel = load('../Data/Eclipse9_cells_discharge.mat'); % Octave

% IMPORTANT DE CHOISIR LES BONS COEFFICIENTS POUR LE CYCLE DU SOLEIL !
%% Charge les coefficients de la courbe de l'irradiance du 41e parallele Nord.  **** Voir le fichier TESTsolarradiation.m pour plus de details. ****
% load('SolarIrradianceLat41N.mat', 'irrandiance_coef');
% Charge les coefficients du cycle du soleil pour la FSGP2016
%load('SoleilFSGPcoef.mat');
load('../Data/SoleilFSGPcoef.mat'); % Octave

%% Importation des donnees du circuit a realiser (Voir "traitementDonneesGPS.m")
%load('etapesASC2016_continuous.mat')
%load('TrackPMGInner10m.mat')
load('../Data/TrackPMGInner10m.mat') % Octave
%load('PittRaceNorthTrack10m.mat')
% Parcours = newParcours;
Parcours.Longitude = newParcours.longitude(1);
Parcours.Latitude = newParcours.latitude(1);


%% Pr�visions solaires
% run('sunForecast.m');    % Tentative de mettre � jour les pr�visions solaires
load('../Data/SunForecastFSGP2017-Jul-08.mat'); % Charge les meilleures pr�visions solaires disponibles

%% Constantes physiques 
constantes.const_grav = 9.81;      % m/s^2
constantes.constante_universelle_gaz_parfaits = 8.3144621; % J/(k*mol)Constante universelle des gaz parfaits
constantes.zero_absolu = 273.15; % Ecart entre zero degre Celcius et degres Kelvins
constantes.masse_molaire_air = 28.965338/1000; % kg/mol


%% Contraintes du parcour
strategy.SoC_ini = 1;         % State of Charge actuel(%)
strategy.SoC_min = 0.3;         % Final State of Charge (%)
strategy.vitesse_min = 15/3.6;   % m/s (20 km/h)
strategy.vitesse_moy = 75/3.6;   % m/s  *** VITESSE CIBLE ***
strategy.vitesse_max = 120/3.6;  % m/s (120 km/h)
strategy.vitesse_ini = 0;        % m/s
strategy.accel_nom = 0.1;        % m/s^2
strategy.accel_max = 1;          % m/s^2
strategy.decel_nom = -0.03;      % m/s^2


%% Reglements de la FSGP 2017 rev. A
reglement.heure_depart = 9/24; % Depart a 9h00 CDT     (10h la premiere journee de la FSGP) (Actuellement a 13h15)
reglement.heure_arret = 17/24; % Arret a 18h00 CDT   (17h les deux dernieres journees de la FSGP)
reglement.impound_out = 7/24; % Batterie disponible a partir de 7h00 CDT
reglement.impound_in = 20/24; % Batterie non-disponible a partir de 20h00 CDT
reglement.fsgp_fin_recharge_matin = 9/24; % Fin de la recharge du matin a 8h30 CDT
% reglement.checkpoint = [350.762]; % km (Distance avant chaque checkpoint) **** ETAPE 1 UNIQUEMENT ****


%% Donnees meteo
% Les donnees meteos peuvent etre divisee en vecteurs [1xn] pour separer l'information en n tranches de journees
% ex. meteo.temperature = [20 28] -> 20deg 7hjusqu'a midi et 28deg midi jusqu'a 20h
meteo.vitesse_vent = [0 0]; % km/h
meteo.direction_vent = [0 0]; % degres 
meteo.couverture_ciel = [2.1/6 2.1/6]; % Pourcentage du ciel degage (Multiplie la puissance calculee des panneaux)
meteo.pression_atmospherique = [101.2 101.2]; % kPa
meteo.temperature = [28 28]; % Degre celcius
meteo.mv_air = 1000*meteo.pression_atmospherique*constantes.masse_molaire_air ./ (constantes.constante_universelle_gaz_parfaits * (constantes.zero_absolu + meteo.temperature)); % kg/m^3
meteo.sun_cycle_coef = sun_coef;
meteo.global_horizontal_irradiance = solarForecast.global_horizontal_irradiance;
meteo.direct_irradiance = solarForecast.global_direct_irradiance;
meteo.dateVec_irradiance = solarForecast.date;

%% CONSTANTES OBSOLETES
% constantes.tempAmbiant = 273.15+20;  % Temperature ambiante (Kelvin)
% constantes.absolutePressure = 101.325 * 1000; % Pa
% constantes.specificAirConstant = 287.058; % J/(kg*K)
% constantes.mv_air = constantes.absolutePressure/(constantes.specificAirConstant*constantes.tempAmbiant);     % kg/m^3         % TODO : Transformer en �quation en fonction de la pression atmosph�rique et de la temp�rature
% constantes.vitesse_vent = 20/3.6; % m/s
% constantes.direction_vent = 220; % degres
% constantes.irrandiance_coef = irrandiance_coef; % Coefficients du polinome representant la densite de puissance incidente du soleil
% constantes.densite_de_puissance_incidente = 800; % W/m^2                ******* TODO : A changer *******


%% Parametres du vehicule Eclipse 9
% Infos sur les param�tres du moteur :
% http://lati-solar-car.wikispaces.com/file/view/Solar+Car+Wheel+Motor+Information+Sheet.pdf
eclipse9.masse_totale = 295;     % kg % ECLIPSE 9 : 220 kg sans pilote, pilote avec ballastes : 80 kg
eclipse9.aire_frontale = 1.26;   % m^2
eclipse9.coef_trainee = 0.233; % Calcule le 30 juillet 2016 ASC jour 1  %0.125;%0.135;  %Test le 10 juin 2017 a PMG : 0.233
%eclipse9.coef_trainee = 0.25;      % ECLIPSE 9 SANS COQUE
eclipse9.coef_roulement = 0.0073 ; % Test le 10 juin 2017 a PMG : 0.0073  % 1 moteur qui frotte � la FSGP 2017 : 0.016
eclipse9.frottement = eclipse9.masse_totale * eclipse9.coef_roulement * constantes.const_grav;       % N - 
eclipse9.rayon_roue = 0.2725;    % m                                        
eclipse9.surface_solaire = 5.994;    % m^2
eclipse9.nb_roue = 4;            % Nombre de roues
eclipse9.largeur_pneu = 0.0635;    % m                              
eclipse9.hauteur_roue = 2*eclipse9.rayon_roue;     % m             
eclipse9.nb_moteur = 1;
eclipse9.vitesse_nom = 111;    % rad/s (Pour un moteur)
eclipse9.couple_nom = 16.2;    % Nm    (Pour un moteur)
eclipse9.couple_max = 80;      % Nm    (Pour un moteur)
eclipse9.puissance_max = 1800; % W     (Pour un moteur)
eclipse9.NbCellPV = 391;
eclipse9.SurfaceCellPV = 0.01533282; % m^2
eclipse9.SurfaceTotalePV = eclipse9.NbCellPV * eclipse9.SurfaceCellPV;
eclipse9.EfficaciteSunPowerBinH = 0.233; % (%)
eclipse9.nb_cell_serie = 38;
eclipse9.nb_cell_para = 11;
eclipse9.nb_cell_total = eclipse9.nb_cell_serie*eclipse9.nb_cell_para;
eclipse9.Ecell_max = 4.2;    % V
eclipse9.Ecell_min = 2.6;    % V
eclipse9.Ccell = 2.9599;     % Ah Valeur mesur�e par JF mai 2017
eclipse9.Crate_max = 2;
eclipse9.Rcell = 0.125;      % ohm (NRC18560B from http://lygte-info.dk/review/batteries2012/Common18650Summary%20UK.html) 
eclipse9.Ebatt_max = eclipse9.Ecell_max*eclipse9.nb_cell_serie; % V max
eclipse9.Ibatt_max = eclipse9.Crate_max*eclipse9.Ccell*eclipse9.nb_cell_para;   % Courant de la batterie � 2 C
eclipse9.Ibatt_nom = eclipse9.Ccell*eclipse9.nb_cell_para;             % Courant de la batterie � 1 C
eclipse9.Rint = eclipse9.nb_cell_serie/eclipse9.nb_cell_para*eclipse9.Rcell;    % ohm
eclipse9.Battery_capacity = eclipse9.Ccell * eclipse9.nb_cell_total;   % kWh


%% Valeurs initiales au depart
etat_course.journee = 1;
etat_course.SoC_start = strategy.SoC_ini; % (%)
etat_course.nbLap = 0;
etat_course.nbLapMax = 1;
etat_course.vitesse_ini = 0; % m/s
etat_course.heure_depart = datenum([2017,07,09,reglement.heure_depart*24,0,0]); % Format de l'heure : [yyyy, mm, jj, hh, mm, ss]

 