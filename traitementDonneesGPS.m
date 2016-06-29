%% %% �clipse 9
%  Auteur : Julien Longchamp
%  Date de cr�ation : 15-06-2016
%  Derni�re modification : 28-06-2015 JL
%
% Ce script permet de traiter un fichier de donn�es GPS en format .csv vers
% le format .mat
% En plus de convertir le fichier en vecteurs, certaines op�rations
% suppl�mentaires sont effectu�es afin d'ajouter des points interm�diaires
% entre chaque paire de points distanc�s de plus de 100 m�tres et de
% recalculer la pente entre deux points.

% ************************ IMPORTANT *************************************
% Dans le pr�sent script, il est n�cessaire de changer le nom de fichier
% source et du fichier de destination tel qu'indiqu� plus loin.
% ************************************************************************

%  Cette function doit �tre utilis�e avec un fichier pr�alablement cr�� �
%  partir du site http://www.gpsvisualizer.com/convert_input?convert_format

%  Instructions pour cr�er un fichier CSV   
%  1- Cr�er un fichier .kml � partir de Google Earth ou autre.
%  2- Cocher les options suivantes sur le site de GPSVisualizer :
%       Output format: Plain test
%       Plain text delimiter: semi-colon
%       Add estimated fields: slope(%), distance
%       Add DEM elevation dada: USGS NED1
%  3- Cliquer sur Convert et copier le texte en sortie dans Excel
%  4- Supprimer la deuxi�me ligne qui contient des informations inutiles
%  (coller les donn�es restantes ensemble, ne pas laisser de ligne vide)
%  5- Sauvegarder le fichier .csv � l'aide d'Excel (*** IMPORTANT de
%  sauvegarder en format .csv)

%  Instructions pour importer le fichier CVS dans Matlab
%  1 - Utiliser la fonction "importGPSfromCSV.m" pour lire le fichier CSV
%  2 - Utiliser la fonction "interpolationGPSdata.m" pour ajouter des points interm�diaires � tous les 100 m�tres
%  *** N'oubliez pas de renommez les fichiers de sortie des deux fonctions pr�c�dentes!
%  3 - Vous pouvez � pr�sent utiliser les fichiers main_simulateur.m et optim_etapes.m

clc, clear all, close all

% ************************ IMPORTANT *************************************
% Remplacer le nom du fichier source et du fichier cible ci-dessous
% ************************************************************************
% exemple :
%fichier_source = 'R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape1.csv';
%fichier_cible = 'R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\ASC2016_etape1.csv'
fichier_source = 'R:\ELE\Eclipse 9\Projet\Simulateur d''autonomie\donnees_gps\TrackPMGInner.csv';
fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\TrackPMGInner10m.mat'
%fichier_cible = 'C:\Users\club\Git\StrategieCourseASC2016\Test.mat'
% Charge un fichier source .csv dont le format est [Type Latitude Longitude Altitude(m) Distance(km) Interval(m)]
parcours = importGPSfromCSV(fichier_source);
newParcours = linearInterpolationGPSdata(parcours, 10);

save(fichier_cible, 'newParcours')

figure, plot(parcours.latitude, parcours.longitude, '.')
figure, plot3(parcours.latitude, parcours.longitude, parcours.altitude, '.')

figure, plot(newParcours.latitude, newParcours.longitude, '.r')
figure, plot3(newParcours.latitude, newParcours.longitude, newParcours.altitude, 'r.')

figure, hold on
plot(parcours.distance, parcours.altitude, '.')
plot(newParcours.distance, newParcours.altitude, 'r.')
figure, plot(newParcours.distance, newParcours.slope)
figure, plot(newParcours.slope)



