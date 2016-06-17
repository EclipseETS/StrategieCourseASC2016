function newData = interpolationGPSdata(data)

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


%data = load('etapesASC2016.mat');

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

%% Ajustement de l'altitude et recalcul de la pente puisque la valeur de 'slope' est bidon
for field = fieldnames(newData)'
    % Prétraitement de la pente (slope) à l'aide d'un FIR rectangulaire (30 échantillons de large)
    for k=1:length(newData.(field{1}).slope)
        newData.(field{1}).altitude(k) = mean(newData.(field{1}).altitude(max([1 k-30]):k));
    end
    newData.(field{1}).slope = zeros(size(newData.(field{1}).slope));
    for k=2:length(newData.(field{1}).slope)
        newData.(field{1}).slope(k) = 100*(newData.(field{1}).altitude(k)-newData.(field{1}).altitude(k-1))/(newData.(field{1}).distance_interval(k));
    end
end

etape1 = newData.etape1;
etape2 = newData.etape2;
etape3 = newData.etape3;
etape4 = newData.etape4;

save('etapesASC2016_continuous2.mat', 'etape1', 'etape2', 'etape3', 'etape4');

%% Figures pour validation
figure, hold on, title('Interpolation des coordonnées GPS')
plot(newData.etape3.longitude, newData.etape3.latitude, 'ro');
plot(data.etape3.longitude, data.etape3.latitude, '*');
legend('Nouveaux points', 'Tracé original', 'location', 'southeast')
xlabel('longitude')
ylabel('latitude')

figure, hold on, title('Intervals de distance (m)')
plot(data.etape1.distance_interval, 'b*');
plot(newData.etape1.distance_interval, 'ro');

figure, hold on,  title('Élévation de etape1');
subplot(2,1,1), plot(etape1.distance, etape1.altitude)
ylabel('Altitude (m)')
subplot(2,1,2), hold on,
plot(etape1.distance, etape1.slope)
ylabel('Pente (%)')
xlabel('Distance (km)')

figure, hold on,  title('Élévation de etape2');
subplot(2,1,1), plot(etape2.distance, etape2.altitude)
ylabel('Altitude (m)')
subplot(2,1,2), hold on,
plot(etape2.distance, etape2.slope)
ylabel('Pente (%)')
xlabel('Distance (km)')

figure, hold on,  title('Élévation de etape3');
subplot(2,1,1), plot(etape3.distance, etape3.altitude)
ylabel('Altitude (m)')
subplot(2,1,2), hold on,
plot(etape3.distance, etape3.slope)
ylabel('Pente (%)')
xlabel('Distance (km)')

figure, hold on,  title('Élévation de etape4');
subplot(2,1,1), plot(etape4.distance, etape4.altitude)
ylabel('Altitude (m)')
subplot(2,1,2), hold on,
plot(etape4.distance, etape4.slope)
ylabel('Pente (%)')
xlabel('Distance (km)')
