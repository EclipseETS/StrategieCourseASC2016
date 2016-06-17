function newData = linearInterpolationGPSdata(data)

%% �clipse 9
%  Interpolation des donn�es GPS
%
%  Cette fonction permet d'introduire des points par interpolations lin�aire dans un
%  fichier de coordonn�es GPS cr�� � l'aide du fichier importGPSfromCSV.m
%
%  Les coordonn�es en sortie de la fonction sont distanc�es au maximum de 100 m�tres  
%
%  Auteur : Julien Longchamp
%  Date de cr�ation : 15-06-2016
%%


%data = load('etapesASC2016.mat');
display_figures = 0;

newData = data;
distance_moyenne = 100; % (m) Distance moyenne souhait�e entre deux points 
n = 1;


nbPoints = length(data.distance);
decalage = 0;
for k=2:nbPoints
    if (data.distance_interval(k) > distance_moyenne)
        
        nouvPoints = ceil(data.distance_interval(k)./distance_moyenne);  % On calcule le nombre de points � ajouter
        entryCut = decalage + k-1;
        exitCut = decalage + k+1;
        decalage = decalage + nouvPoints - 1;   % On accumule un d�calage entre l'ancien et le nouveau vecteur
        B = newData.latitude;
        for subfield = fieldnames(newData)'
            interval = (data.(subfield{1})(k) - data.(subfield{1})(k-1))/nouvPoints;
            newData.(subfield{1}) = [newData.(subfield{1})(1:entryCut); ...
                newData.(subfield{1})(entryCut) + interval.*(1:nouvPoints)'; ...
                newData.(subfield{1})(exitCut:end)];
        end
        newData.distance_interval = 1000*[0; diff(newData.distance)]; % Recalcul des intervals de distance            
    end
end



%% Ajustement de l'altitude et recalcul de la pente puisque la valeur de 'slope' est bidon
% Pr�traitement de la pente (slope) � l'aide d'un FIR rectangulaire (5 �chantillons de large)
FIRsize = 5; % Largeur de la fen�tre du filtre passe-bas de type FIR ordre 1
suspiciousGradePercent = 5; % Pourcentage � partir duquel une v�rification est fa�te sur le pourcentage de la pente
for k=1:length(newData.slope)
    newData.altitude(k) = mean(newData.altitude(max([1 k-FIRsize]):k));
end
% Les donnees sont d�cal�es pour compenser le retard introduit par le filtre
newData.altitude = [newData.altitude(FIRsize+1:end) ; newData.altitude(1:FIRsize) ];

newData.slope = zeros(size(newData.slope));
for k=3:length(newData.slope)
    newData.slope(k) = 100*(newData.altitude(k)-newData.altitude(k-1))/(newData.distance_interval(k));
    if abs(newData.slope(k-1)) > suspiciousGradePercent
        SA = abs(newData.slope(k) - newData.slope(k-1));
        SB = abs(newData.slope(k-1) - newData.slope(k-2));
        if abs(SA-SB)/mean([SA,SB]) < 0.1
            newData.slope(k-1) = newData.slope(k-2)
        end        
    end
end
 


%save('etapesASC2016_continuous2.mat', 'etape1', 'etape2', 'etape3', 'etape4');

if display_figures
%% Figures pour validation
figure, hold on, title('Interpolation des coordonn�es GPS')
plot(newData.longitude, newData.latitude, 'ro');
plot(data.longitude, data.latitude, '*');
legend('Nouveaux points', 'Trac� original', 'location', 'southeast')
xlabel('longitude')
ylabel('latitude')

figure, hold on, title('Intervals de distance (m)')
plot(data.distance_interval, 'b*');
plot(newData.distance_interval, 'ro');

figure, hold on,  title('�l�vation de newData');
subplot(2,1,1), plot(newData.distance, newData.altitude)
ylabel('Altitude (m)')
subplot(2,1,2), hold on,
plot(newData.distance, newData.slope)
ylabel('Pente (%)')
xlabel('Distance (km)')
end
