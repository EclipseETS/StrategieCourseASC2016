%% Eclipse 
%  Le script parameterGeneratorEclipseX.m  permet de fixer toute les
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
%                          08-06-2018 (ML) Changement de variables
%% Importation des modeles statiques
% Importation des courbes de decharge des cellules NCR18650BF
cellModel = load('../Data/Eclipse9_cells_discharge.mat'); % Octave

%% Importation des donnees du circuit a realiser (Voir "traitementDonneesGPS.m")
load('../Data/TrackPMGInner10m.mat') % Octave
Parcours.Longitude = newParcours.longitude(1);
Parcours.Latitude = newParcours.latitude(1);

%% Prévisions solaires
% Mettre a jour les donnees solaire au besoin
% run('sunForecast.m');    % Tentative de mettre à jour les prévisions solaires
load('../Data/SunForecastFSGP2018-Jun-26.mat'); % Charge les meilleures prévisions solaires disponibles

%% Constantes physiques 
constantes.const_grav = 9.81;      % m/s^2
constantes.constante_universelle_gaz_parfaits = 8.3144621; % J/(k*mol)Constante universelle des gaz parfaits
constantes.zero_absolu = 273.15; % Ecart entre zero degre Celcius et degres Kelvins
constantes.masse_molaire_air = 28.965338/1000; % kg/mol


%% Contraintes du parcour
strategy.SoC_ini = 1;         % State of Charge actuel(%)
strategy.SoC_min = 0.2;         % Final State of Charge (%)
strategy.vitesse_min = 15/3.6;   % m/s (20 km/h)
strategy.vitesse_moy = 65/3.6;   % m/s  *** VITESSE CIBLE ***
strategy.vitesse_max = 120/3.6;  % m/s (120 km/h)
strategy.vitesse_ini = 0;        % m/s
strategy.accel_nom = 0.1;        % m/s^2
strategy.accel_max = 1;          % m/s^2
strategy.decel_nom = -0.03;      % m/s^2


%% Reglements de la FSGP 2018
reglement.heure_depart = 10/24; % Depart a 9h00 CDT     (10h la premiere journee de la FSGP) (Actuellement a 13h15)
reglement.heure_arret = 18/24; % Arret a 18h00 CDT   (17h les deux dernieres journees de la FSGP)
reglement.impound_out = 7/24; % Batterie disponible a partir de 7h00 CDT
reglement.impound_in = 18/24; % Batterie non-disponible a partir de 20h00 CDT
reglement.fsgp_fin_recharge_matin = 9/24; % Fin de la recharge du matin a 8h30 CDT


%% Donnees meteo
% Les donnees meteos peuvent etre divisee en vecteurs [1xn] pour separer l'information en n tranches de journees
% ex. meteo.temperature = [20 28] -> 20deg 7hjusqu'a midi et 28deg midi jusqu'a 20h
meteo.vitesse_vent = [0 0]; % km/h
meteo.direction_vent = [0 0]; % degres 
meteo.pression_atmospherique = [101.2 101.2]; % kPa
meteo.temperature = [28 28]; % Degre celcius
meteo.mv_air = 1000*meteo.pression_atmospherique*constantes.masse_molaire_air ./ (constantes.constante_universelle_gaz_parfaits * (constantes.zero_absolu + meteo.temperature)); % kg/m^3
meteo.global_horizontal_irradiance = solarForecast.global_horizontal_irradiance;
meteo.normal_irradiance = solarForecast.global_direct_irradiance;
meteo.dateVec_irradiance = solarForecast.date;

%% Parametres du vehicule Eclipse 9
% Infos sur les paramètres du moteur :
% http://lati-solar-car.wikispaces.com/file/view/Solar+Car+Wheel+Motor+Information+Sheet.pdf
Eclipse.masse_totale = 230;     % kg % ECLIPSE 9 : 220 kg sans pilote, pilote avec ballastes : 80 kg
Eclipse.aire_frontale = .9;   % m^2
Eclipse.coef_trainee = 0.13; % Calculer le 10 juin 2018 chez PMG
Eclipse.coef_roulement = 0.01 ; % Calculer le 10 juin 2018 chez PMG
Eclipse.frottement = Eclipse.masse_totale * Eclipse.coef_roulement * constantes.const_grav;       % N - 
Eclipse.rayon_roue = 0.2725;    % m                                        
Eclipse.surface_solaire = 5.994;    % m^2
Eclipse.nb_roue = 4;            % Nombre de roues
Eclipse.largeur_pneu = 0.0635;    % m                              
Eclipse.hauteur_roue = 2*Eclipse.rayon_roue;     % m             
Eclipse.nb_moteur = 1;
Eclipse.vitesse_nom = 111;    % rad/s (Pour un moteur)
Eclipse.couple_nom = 16.2;    % Nm    (Pour un moteur)
Eclipse.couple_max = 80;      % Nm    (Pour un moteur)
Eclipse.puissance_max = 1800; % W     (Pour un moteur)
Eclipse.NbCellPV = 260;
Eclipse.NbCellPV_recharge = 390;
Eclipse.SurfaceCellPV = 0.01533282; % m^2
Eclipse.SurfaceTotalePV = Eclipse.NbCellPV * Eclipse.SurfaceCellPV;
Eclipse.SurfaceTotalePV_recharge = Eclipse.NbCellPV_recharge * Eclipse.SurfaceCellPV;
Eclipse.EfficaciteSunPowerBinH = 0.243; % (%)
Eclipse.nb_cell_serie = 32;
Eclipse.nb_cell_para = 13;
Eclipse.nb_cell_total = Eclipse.nb_cell_serie*Eclipse.nb_cell_para;
Eclipse.Ecell_max = 4.2;    % V
Eclipse.Ecell_min = 3.1;    % V
Eclipse.Ccell = 3.4;     % Ah Valeur mesurée par JF juin 2018
Eclipse.Crate_max = 2;
Eclipse.Rcell = 0.125;      % ohm (NRC18560B from http://lygte-info.dk/review/batteries2012/Common18650Summary%20UK.html) 
Eclipse.Ebatt_max = Eclipse.Ecell_max*Eclipse.nb_cell_serie; % V max
Eclipse.Ibatt_max = Eclipse.Crate_max*Eclipse.Ccell*Eclipse.nb_cell_para;   % Courant de la batterie à 2 C
Eclipse.Ibatt_nom = Eclipse.Ccell*Eclipse.nb_cell_para;             % Courant de la batterie à 1 C
Eclipse.Rint = Eclipse.nb_cell_serie/Eclipse.nb_cell_para*Eclipse.Rcell;    % ohm
Eclipse.Battery_capacity = Eclipse.Ccell * Eclipse.nb_cell_total;   % kWh


%% Valeurs initiales au depart
etat_course.journee = 1;
etat_course.SoC_start = strategy.SoC_ini; % (%)
etat_course.nbLap = 0;
etat_course.nbLapMax = 1;
etat_course.vitesse_ini = 0; % m/s
etat_course.heure_depart = datenum([2018,06,26,reglement.heure_depart*24,0,0]); % Format de l'heure : [yyyy, mm, jj, hh, mm, ss]

%% Moyenne de soleil
Soleil.Debut_journee = datevec(etat_course.heure_depart) ; %[yyyy, mm, jj, hh, mm, ss]
Soleil.Fin_journee = [Soleil.Debut_journee(1:3) reglement.heure_arret*24 0 0]  ; 
Soleil.Fin_recharge = [Soleil.Debut_journee(1:3) reglement.impound_in*24 0 0] ;
Soleil.Debut_recharge = [Soleil.Debut_journee(1:2) Soleil.Debut_journee(3)+1 reglement.impound_out*24 0 0];
Soleil.Demies_heures = reglement.heure_depart*24 :0.5: reglement.heure_arret*24; % 9h séparer en tranches de 30 mins
Soleil.Demies_heures = Soleil.Demies_heures (1,2:end);
Soleil.Demies_heures_impound = reglement.impound_out*24 :0.5: reglement.impound_in*24; % 9h séparer en tranches de 30 mins
Soleil.Demies_heures_impound = Soleil.Demies_heures_impound (1,2:end);
Soleil.Moyenne_soleil = zeros(length(Soleil.Demies_heures),1);

for Index_Time = 1 : length (Soleil.Demies_heures)
    Soleil.heureArrondieVec = [floor(Soleil.Demies_heures(Index_Time)) mod(Soleil.Demies_heures (Index_Time),1)*60 0];
    Soleil.Journee = datevec(datenum([Soleil.Debut_journee(1:3) Soleil.heureArrondieVec]));
    
    Soleil.indexPV = find(ismember (meteo.dateVec_irradiance, Soleil.Journee, 'rows'));
    Soleil.Moyenne_soleil(Index_Time) = meteo.global_horizontal_irradiance(Soleil.indexPV)* Eclipse.SurfaceTotalePV * Eclipse.EfficaciteSunPowerBinH;
end
% 
% for Index_Time = 1 : length (Demies_heures_impound)
%     heureArrondieVec = [floor(Demies_heures_impound(Index_Time)) mod(Demies_heures_impound (Index_Time),1)*60 0];
%     recharge = datevec(datenum([Debut_journee(1:3) heureArrondieVec]));
%     
%     indexPV = find(ismember (meteo.dateVec_irradiance, recharge, 'rows'));
%     Moyenne_soleil(Index_Time) = meteo.global_horizontal_irradiance(indexPV)* Eclipse.SurfaceTotalePV_recharge * Eclipse.EfficaciteSunPowerBinH;
% end

Soleil.Moyenne_soleil_total = round(mean(Soleil.Moyenne_soleil));
fprintf('L''energie moyenne recu du soleil est de %d W durant la journee\n', Soleil.Moyenne_soleil_total);
% 
%%
% Graphique de l'ensoleillement
% h1 = figure;
% hold on, grid on, title('Taux d''ensoleillement')
% figure(h1)
% plot (Soleil.Demies_heures, Soleil.Moyenne_soleil)