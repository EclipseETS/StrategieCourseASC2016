function data = importGPSfromCSV(filename, startRow, endRow)

% importGPSfromCSV Import numeric data from a text file as column vectors.
%   data = importGPSfromCSV(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   data = importGPSfromCSV(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   data = importGPSfromCSV('ASC2016_etape1.csv',2, 7845);
%
%    See also TEXTSCAN.

%% �clipse 9
%  Auteur : Julien Longchamp
%  Date de cr�ation : 26-02-2016
%  Derni�re modification : 15-06-2016

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



%% Initialize variables.
delimiter = ' ';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
%data.type = dataArray{:, 1};             % Type de donn�es (pas utilis�)
data.latitude = dataArray{:, 2};         % Coordonn�es d�cimale
data.longitude = dataArray{:, 3};        % Coordonn�es d�cimale
data.altitude = dataArray{:, 4};         % Altitude en m�tre
data.slope = dataArray{:, 5};            % Pente en pourcentage
data.distance = dataArray{:, 6};         % Distance cumul�e (km)
data.distance_interval = dataArray{:, 7}; % Intervalle de distance (m)



