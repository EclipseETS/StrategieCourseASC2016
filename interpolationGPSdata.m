%% Éclipse 9
%  Interpolation des données GPS
%
%  Ce script permet d'introduire des points par interpolations dans un
%  fichier de coordonnées GPS créé à l'aide du fichier 
%  importGPSfromCSV.m
%  
%  Auteur : Julien Longchamp
%  Date de création : 10-03-2016
%%
clc, close all, clear all

data = load('etapesASC2016.mat');

newData = data;
distance_moyenne = 100; % (m) Distance moyenne souhaitée entre deux points 
n = 1;
for field = fieldnames(data)'

    nbPoints = length(data.(field{1}).distance);
    decalage = 0;
    for k=2:nbPoints
        if (data.(field{1}).distance_interval(k) > distance_moyenne)
                
            nouvPoints = ceil(data.(field{1}).distance_interval(k)./distance_moyenne);  % On calcule le nombre de points à ajouter            
            entryCut = decalage + k-1;
            exitCut = decalage + k+1;
            decalage = decalage + nouvPoints - 1;   % On accumule un décalage entre l'ancien et le nouveau vecteur            
            B = newData.(field{1}).latitude;
            for subfield = fieldnames(newData.(field{1}))'
                interval = (data.(field{1}).(subfield{1})(k) - data.(field{1}).(subfield{1})(k-1))/nouvPoints;
                newData.(field{1}).(subfield{1}) = [newData.(field{1}).(subfield{1})(1:entryCut); ...
                    newData.(field{1}).(subfield{1})(entryCut) + interval.*(1:nouvPoints)'; ...
                    newData.(field{1}).(subfield{1})(exitCut:end)];               
            end
            newData.(field{1}).distance_interval = 1000*[0; diff(newData.(field{1}).distance)]; % Recalcul des intervals de distance
            

        else
            
        end
    end 
    
end
etape1 = newData.etape1;
etape2 = newData.etape2;
etape3 = newData.etape3;
etape4 = newData.etape4;
save('etapesASC2016_continuous.mat', 'etape1', 'etape2', 'etape3', 'etape4');

%% Figure pour validation
figure, hold on, title('Interpolation des coordonnées GPS')
plot(newData.etape3.longitude, newData.etape3.latitude, 'ro');
plot(data.etape3.longitude, data.etape3.latitude, '*');
legend('Nouveaux points', 'Tracé original', 'location', 'southeast')
xlabel('longitude')
ylabel('latitude')

figure, hold on, title('Intervals de distance (m)')
plot(data.etape1.distance_interval, 'b*');
plot(newData.etape1.distance_interval, 'ro');
