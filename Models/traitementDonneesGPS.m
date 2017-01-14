%% %% Éclipse 9
%  Auteur : Julien Longchamp
%  Date de création : 15-06-2016
%  Dernière modification : 28-06-2015 JL
%
% Ce script permet de traiter un fichier de données GPS en format .csv vers
% le format .mat
% En plus de convertir le fichier en vecteurs, certaines opérations
% supplémentaires sont effectuées afin d'ajouter des points intermédiaires
% entre chaque paire de points distancés de plus de 100 mètres et de
% recalculer la pente entre deux points.

% ************************ IMPORTANT *************************************
% Dans le présent script, il est nécessaire de changer le nom de fichier
% source et du fichier de destination tel qu'indiqué plus loin.
% ************************************************************************

%  Cette function doit être utilisée avec un fichier préalablement créé à
%  partir du site http://www.gpsvisualizer.com/convert_input?convert_format

%  Instructions pour créer un fichier CSV   
%  1- Créer un fichier .kml à partir de Google Earth ou autre.
%  2- Cocher les options suivantes sur le site de GPSVisualizer :
%       Output format: Plain test
%       Plain text delimiter: semi-colon
%       Add estimated fields: slope(%), distance
%       Add DEM elevation dada: USGS NED1
%  3- Cliquer sur Convert et copier le texte en sortie dans Excel
%  4- Supprimer la deuxième ligne qui contient des informations inutiles
%  (coller les données restantes ensemble, ne pas laisser de ligne vide)
%  5- Sauvegarder le fichier .csv à l'aide d'Excel (*** IMPORTANT de
%  sauvegarder en format .csv)

%  Instructions pour importer le fichier CVS dans Matlab
%  1 - Utiliser la fonction "importGPSfromCSV.m" pour lire le fichier CSV
%  2 - Utiliser la fonction "interpolationGPSdata.m" pour ajouter des points intermédiaires à tous les 100 mètres
%  *** N'oubliez pas de renommez les fichiers de sortie des deux fonctions précédentes!
%  3 - Vous pouvez à présent utiliser les fichiers main_simulateur.m et optim_etapes.m

clc, clear all, close all

% ************************ IMPORTANT *************************************
% Remplacer le nom du fichier source et du fichier cible ci-dessous
% ************************************************************************

% ASC 2016
% fichier_source = 'R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape1.csv';
% fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\ASC2016_stage1_plus_speed.mat'
% speed_limit_filename = 'R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_route_stage1.xlsx';

% FSPG 2016
% fichier_source = 'R:\Eclipse\ELE\Eclipse%209\Projet\Simulateur d''autonomie\donnees_gps\PittRaceNorthTrack.csv';
% fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\PittRaceNorthTrack10m.mat'

% PMG
% fichier_source = 'R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\TrackPMGInner.csv';
% fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\TrackPMGInner10m.mat'


% Charge un fichier source .csv dont le format est [Type Latitude Longitude Altitude(m) Distance(km) Interval(m)]
parcours = importGPSfromCSV(fichier_source);

interval_max = 100; % mètres      Distance maximale entre deux points
newParcours = linearInterpolationGPSdata(parcours, interval_max);



figure, plot(parcours.latitude, parcours.longitude, '.')
figure, plot3(parcours.latitude, parcours.longitude, parcours.altitude, '.')

figure, plot(newParcours.latitude, newParcours.longitude, '.r')
figure, plot3(newParcours.latitude, newParcours.longitude, newParcours.altitude, 'r.')

figure, hold on, title('Altitude')
plot(parcours.distance, parcours.altitude, '.')
plot(newParcours.distance, newParcours.altitude, 'r.')
figure, plot(newParcours.distance, newParcours.slope), title('Pente')




%% Ajout de l'information sur la vitesse maximale du parcours
%  Un fichier excel contenant une colone correspondants à la distance totale (en miles) et un colone 
%  correspondant à la vitesse maximale (en mph) doit être fourni
if exist('speed_limit_filename', 'var')
    speed_limit = xlsread(speed_limit_filename);
    for k=2:length(speed_limit)
        if isnan(speed_limit(k,2))
            speed_limit(k,2) = speed_limit(k-1,2);
        end
    end
    
    speed_limit = speed_limit .* 1.609; % Conversion des miles en km et des mph en km/h (1 mile = 1609 mètres)
    
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
