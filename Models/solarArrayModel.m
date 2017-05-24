function [puissancePV, Elevation] = solarArrayModel(heure, densite_de_puissance_incidente, surSupport, sun_coef)

%% Éclipse 9
%  Modèle du système photovoltaïque d'Éclipse 9
%  
%  Ce modèle nécessite l'usage de la fonction SolarAzEl.m de Darin Koblick
%  disponible sur File Exchange à l'adresse suivante :
%  https://www.mathworks.com/matlabcentral/fileexchange/23051-vectorized-solar-azimuth-and-elevation-estimation
%
%  Important d'ajouter le path vers la fonction SolarAzEl.m
%    ex : addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\SolarAzEl');
%
%  Inputs :
%    latitude : Coordonnée GPS décimale
%    longitude : Coordonnée GPS décimale
%    altitude : Altitude en mètres
%    heure : date et heure en format datenum (Voir help datenum)
%    densite_de_puissance_incidente : W/m^2 Valeur calculée avec la fonction solarradianceInstant
%    surSupport : Valeur booléenne pour savoir si les panneaux solaires sont sur le support. (Panneaux perpendiculaire au rayonnement du soleil)
%    
%
%  Auteur : Julien Longchamp
%  Date de création : 04-07-2016
%  Dernière modification :
%%

% Chemin vers le fichier SolarAzEl.m   % En commentaire puisque le fichier
% est inclus par un autre fichier dans le simulateur d'Éclipse 9
%addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\SolarAzEl');

if nargin == 0
    clc, clear all, close all
    addpath('..\Outils\SolarAzEl');
    load('..\Data\SoleilFSGPcoef.mat')
else   
    % Charge le model des paneaux solaires créé avec la fonction solarArrayModel (sans arguments)
    load('PV_efficiency_model.mat', 'PV_efficiency_model');
end

%% Configuration du solar array
NbCellPV = 391;
SurfaceCellPV = 0.01533282; % m^2
SurfaceTotalePV = NbCellPV*SurfaceCellPV;
EfficaciteSunPowerBinH = 0.233; % (%) Cellule SunPower E60

%% Pour caculer la puissance des panneaux à un point d'opération précis
% À exécuter une première fois en appuyant simplement sur F5 pour générer le polynôme
% représentant la courbe d'efficacité des panneaux
if nargin == 0
    % inputs : latitude, longitude, heure, jour
    %     latitude =  41.279017;
    %     longitude = -81.541610;
    latitude = 45.6966; % PittRace
    longitude = -73.8736; % PittRace
    altitude = 0/1000; % km
    pente = 0; % Degrés
    heure = datenum([2016,07,21,20,0,0]);
    densite_de_puissance_incidente = 800;
    surSupport = 0;
    
%     PV_loss_datapoint  = ([3.1  2.5  2.2 2.5  3.0  4.1  6] - 2) / 100; % (%)  Le -2 provient d'un échange de courriel entre Gocherman et LP au sujet de l'encapsulation zero losses
    PV_loss_datapoint  = ([3.1  2.5  2.2 2.5  3.0  4.1  6]-1) / 100; % (%)  Le -2 provient d'un échange de courriel entre Gocherman et LP au sujet de l'encapsulation zero losses
    PV_angle_datapoint = [0    20   40  50   60    80  90];
    
    PV_loss_model = polyfit(PV_angle_datapoint, PV_loss_datapoint, 5);
    
    efficaciteCellPV = EfficaciteSunPowerBinH - PV_loss_datapoint;
    PV_efficiency_model = polyfit(PV_angle_datapoint, efficaciteCellPV, 3);
    save('PV_efficiency_model.mat', 'PV_efficiency_model');

    PV_loss_curve = polyval(PV_loss_model, 0:90);
%     figure, hold on, grid on, title('Pertes dans l''encapsulation PV')
    figure, subplot(2,1,1), hold on, grid on, title('Pertes dans l''encapsulation PV')
    plot(PV_angle_datapoint, PV_loss_datapoint, 'o')
    plot(0:90, PV_loss_curve, 'r')
    xlabel('Angle (deg)')
    ylabel('Losses (W)')
    legend('Manufacturier', 'Approximation')
    
    PV_eff_curve = polyval(PV_efficiency_model, 0:90);
%     figure, hold on, grid on, title('PV Efficiency')
    subplot(2,1,2), hold on, grid on, title('PV Efficiency')
    plot(PV_angle_datapoint, efficaciteCellPV, 'o')
    plot(0:90, PV_eff_curve, 'r')  
    xlabel('Angle (deg)')
    ylabel('Efficiency (%)')
    
    %% MPPT
    % From http://www.drivetek.ch/fileadmin/user_upload/MPPT-Race_Spec_Sheet_Version4_lv_bruegg.pdf
    MPPT_eff_datapoint  = [96.25 97 97.35 97.3 97  96.75 96.5 96.25 96] / 100; % (%)  Le -2 provient d'un échange de courriel entre Gocherman et LP au sujet de l'encapsulation zero losses
    MPPT_power_datapoint = [25    50 100   150  200 250   300  350   400]; % W
    MPPT_loss_datapoint = MPPT_power_datapoint - MPPT_power_datapoint.*MPPT_eff_datapoint;
    
    MPPT_loss_model = polyfit(MPPT_power_datapoint, MPPT_loss_datapoint, 2);
    save('MPPT_loss_model.mat', 'MPPT_loss_model');
    MPPT_loss_curve = polyval(MPPT_loss_model, 0:450);
    
    figure
    subplot(2,1,1), hold on, grid on, title('MPPT Losses')
    plot(MPPT_power_datapoint, MPPT_loss_datapoint, 'o')
    plot(0:450, MPPT_loss_curve)
    xlabel('Input Power (W)')
    ylabel('Losses (%)')
    legend('Manufacturier', 'Approximation')
    
    subplot(2,1,2), hold on, grid on, title('MPPT Efficiency')
    plot(MPPT_power_datapoint, MPPT_eff_datapoint, 'o')
    plot(0:450, ((0:450)-MPPT_loss_curve)./(0:450))
    xlabel('Input Power (W)')
    ylabel('Efficiency (%)')    
    
end

if surSupport == 0
    % Calcul de l'élévation et de l'azimuth du soleil
%     [Az El] = SolarAzEl(heure,latitude,longitude,altitude/1000);
%     [ Elevation Azimuth] = SunElevationInstant(heure,latitude,longitude,altitude);
    Elevation = polyval(sun_coef, mod(heure, 1)); % On calcule l'élévation du soleil à l'aide d'une parabole (Voir sunCycleFSGP2016.m) L'heure doit être comprise entre 0 et 1, on élimine l'année et le jour avec le modulo 1
elseif surSupport == 1
    Elevation = 90; % Panneaux perpendiculaires au soleil
end
% Calcul de la puissance fournie par les panneaux solaires
puissancePV = SurfaceTotalePV * polyval(PV_efficiency_model, abs(90-Elevation)) * densite_de_puissance_incidente * sind(Elevation);

% ********** TODO : AJOUTER LES MPPT **********
  
  
  