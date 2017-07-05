%% %% �clipse 9
%  Auteur : Julien Longchamp
%  Date de cr�ation : 15-06-2016
%  Derni�re modification : 07-02-2017 JL
%
% Ce script permet de traiter un fichier de donn�es GPS en format .csv vers
% le format .mat
% En plus de convertir le fichier en vecteurs, certaines op�rations
% suppl�mentaires sont effectu�es afin d'ajouter des points interm�diaires
% entre chaque paire de points distanc�s de plus de 100 m�tres et de
% recalculer la pente entre deux points.

% ***************************** IMPORTANT ********************************
% Dans le pr�sent script, il est n�cessaire de changer le nom de fichier
% source et du fichier de destination tel qu'indiqu� plus loin.
% ************************************************************************

%  Cette function doit �tre utilis�e avec un fichier pr�alablement cr�� �
%  partir du site http://www.gpsvisualizer.com/convert_input?convert_format

%  Instructions pour cr�er un fichier CSV   
%  1- Cr�er un fichier .kml � partir de Google Earth ou autre.
%  2- Cocher les options suivantes sur le site de GPSVisualizer :
%       Output format: Plain text
%       Plain text delimiter: comma
%       Add estimated fields: slope(%), distance
%       Add DEM elevation dada: USGS NED1
%  3- Cliquer sur Convert et copier le texte en sortie dans Excel
%  4- Supprimer la deuxi�me ligne qui contient des informations inutiles
%  (coller les donn�es restantes ensemble, ne pas laisser de ligne vide)
%  5- Sauvegarder le fichier .csv � l'aide d'Excel (*** IMPORTANT de
%  sauvegarder en format .csv)
% 
% Fonctions utilisees pour le traitement des donnes GPS
% importGPSfromCSV.m -> Permet de lire un fichiers CSV et de le sauvegarder dans une structure Matlab
% interpolationGPSdata.m -> Permet d'ajouter des points interm�diaires � tous les X m�tres

clc, clear all, close all

% ***************************** IMPORTANT ********************************
% Remplacer le nom du fichier source et du fichier cible ci-dessous
% ************************************************************************

% ASC 2016
% fichier_source = 'R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape1.csv';
% fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\ASC2016_stage1_plus_speed.mat'
% speed_limit_filename = 'R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_route_stage1.xlsx';

% FSGP 2016
% fichier_source = 'R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\PittRaceNorthTrack.csv';
% fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\PittRaceNorthTrack10m.mat'

% PMG
% fichier_source = 'R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\TrackPMGInner.csv';
% fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\TrackPMGInner10m.mat'

% CoTA (FSGP 2017)
fichier_source = 'C:\Users\ClubEclipse\Downloads\CircuitOfTheAmericas.csv';
fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\CircuitOfTheAmericas20m.mat'

% ***************************** IMPORTANT ****************************************
% Ajuster la distance maximale entre chaque point si n�cessaire (Standard : 100 m)
% ********************************************************************************
interval_max = 20; % m�tres      Distance maximale entre deux points


% Charge un fichier source .csv dont le format est [Type Latitude Longitude Altitude(m) Distance(km) Interval(m)]
parcours = importGPSfromCSV(fichier_source);
newParcours = linearInterpolationGPSdata(parcours, interval_max);

% G�n�re des figures 2D et 3D du parcours.
figure, hold on, title('Carte 2D du parcours')
plot(parcours.latitude, parcours.longitude, '*')
plot(newParcours.latitude, newParcours.longitude, '.r')
legend('Donn�es brutes', 'Donn�es trait�es', 'location', 'southeast')
xlabel('Longitude')
ylabel('Latitude')

figure, hold on, title('Carte 3D du parcours')
plot3(parcours.latitude, parcours.longitude, parcours.altitude, '*')
plot3(newParcours.latitude, newParcours.longitude, newParcours.altitude, 'r.')
legend('Donn�es brutes', 'Donn�es trait�es', 'location', 'southeast')
xlabel('Longitude')
ylabel('Latitude')
zlabel('Altitude (m)')

figure, hold on, title('Altitude')
plot(parcours.distance, parcours.altitude, '.')
plot(newParcours.distance, newParcours.altitude, 'r.')
legend('Donn�es brutes', 'Donn�es trait�es')
xlabel('Distance (km')
ylabel('Altitude (m)')

figure, hold on, title('Pente filtr�e')
plot(newParcours.distance, newParcours.slope)
xlabel('Distance (km')
ylabel('Pente (%)')


%% Ajout de l'information sur la vitesse maximale du parcours
%  Un fichier excel contenant une colone correspondants � la distance totale (en miles) et un colone 
%  correspondant � la vitesse maximale (en mph) doit �tre fourni
if exist('speed_limit_filename', 'var')
    speed_limit = xlsread(speed_limit_filename);
    for k=2:length(speed_limit)
        if isnan(speed_limit(k,2))
            speed_limit(k,2) = speed_limit(k-1,2);
        end
    end
    
    speed_limit = speed_limit .* 1.609; % Conversion des miles en km et des mph en km/h (1 mile = 1609 m�tres)
    
    newParcours.speed_limit = zeros(size(newParcours.distance));
    
    indexSL = 1;
    
    for k=1:length(newParcours.speed_limit)
        newParcours.speed_limit(k) = speed_limit(indexSL,2);
        if newParcours.distance(k) > speed_limit(indexSL,1)
            indexSL = indexSL + 1;
        end
    end
    
    figure, hold on, grid on
    plot(speed_limit(:,1), speed_limit(:,2), 'o')
    plot(newParcours.distance, newParcours.speed_limit, 'r')
end


% save(fichier_cible, 'newParcours')
