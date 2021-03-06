function puissancePV = solarArrayModel(latitude, longitude, altitude, pente, heure, densite_de_puissance_incidente, surSupport)

%% �clipse 9
%  Mod�le du syst�me photovolta�que d'�clipse 9
%  
%  Ce mod�le n�cessite l'usage de la fonction SolarAzEl.m de Darin Koblick
%  disponible sur File Exchange � l'adresse suivante :
%  https://www.mathworks.com/matlabcentral/fileexchange/23051-vectorized-solar-azimuth-and-elevation-estimation
%
%  Important d'ajouter le path vers la fonction SolarAzEl.m
%    ex : addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\SolarAzEl');
%
%  Inputs :
%    latitude : Coordonn�e GPS d�cimale
%    longitude : Coordonn�e GPS d�cimale
%    altitude : Altitude en m�tres
%    heure : date et heure en format datenum (Voir help datenum)
%    densite_de_puissance_incidente : W/m^2 Valeur calcul�e avec la fonction solarradianceInstant
%    surSupport : Valeur bool�enne pour savoir si les panneaux solaires sont sur le support. (Panneaux perpendiculaire au rayonnement du soleil)
%    
%
%  Auteur : Julien Longchamp
%  Date de cr�ation : 04-07-2016
%  Derni�re modification :
%%

% Chemin vers le fichier SolarAzEl.m   % En commentaire puisque le fichier
% est inclus par un autre fichier dans le simulateur d'�clipse 9
%addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\SolarAzEl');

if nargin == 0
    clc, clear all, close all
    addpath('C:\Users\club\Git\StrategieCourseASC2016\Outils\SolarAzEl');
else   
    
    % Charge le model des paneaux solaires cr�� avec la fonction solarArrayModel (sans arguments)
    load('PV_efficiency_model.mat', 'PV_efficiency_model');
end

%% Configuration du solar array
NbCellPV = 391;
SurfaceCellPV = 0.01533282; % m^2
SurfaceTotalePV = NbCellPV*SurfaceCellPV;
EfficaciteSunPowerBinH = 0.233; % (%)

%% Pour caculer la puissance des panneaux � un point d'op�ration pr�cis
% � ex�cuter une premi�re fois en appuyant simplement sur F5 pour g�n�rer le polyn�me
% repr�sentant la courbe d'efficacit� des panneaux
if nargin == 0
    % inputs : latitude, longitude, heure, jour
    %     latitude =  41.279017;
    %     longitude = -81.541610;
    latitude = 45.495122;
    longitude = -73.553607;
    altitude = 10; % m�tres
    pente = 0;
    heure = datenum([2016,07,04,10,0,0]);
    densite_de_puissance_incidente = 800;
    
    PV_loss_datapoint  = ([3.1  2.5  2.0 2.5  3.0  4.1  6] - 2) / 100; % (%)  Le -2 provient d'un �change de courriel entre Gocherman et LP au sujet de l'encapsulation zero losses
    PV_angle_datapoint = [0    20   40  50   60    80  90];
    
    PV_loss_model = polyfit(PV_angle_datapoint, PV_loss_datapoint, 5);
    
    efficaciteCellPV = EfficaciteSunPowerBinH - PV_loss_datapoint;
    PV_efficiency_model = polyfit(PV_angle_datapoint, efficaciteCellPV, 3);
    save('PV_efficiency_model.mat', 'PV_efficiency_model');

    PV_loss_curve = polyval(PV_loss_model, 0:90);
    figure, hold on, grid on
    plot(PV_angle_datapoint, PV_loss_datapoint, 'o')
    plot(0:90, PV_loss_curve, 'r')
    
    PV_eff_curve = polyval(PV_efficiency_model, 0:90);
    figure, hold on, grid on
    plot(PV_angle_datapoint, efficaciteCellPV, 'o')
    plot(0:90, PV_eff_curve, 'r')
end

if surSupport == 0
    % Calcul de l'�l�vation et de l'azimuth du soleil
    [Az El] = SolarAzEl(heure,latitude,longitude,altitude);
elseif surSupport == 1
    El = 0; % Panneaux perpendiculaires au soleil
end
% Calcul de la puissance fournie par les panneaux solaires
puissancePV = SurfaceTotalePV * polyval(PV_efficiency_model, abs(El)) * densite_de_puissance_incidente;
  
% ********** TODO : AJOUTER LES MPPT **********
  
  
  