%% �clipse 9
%  Le script course_sur_route.m permet de simuler la performance d'une
%  voiture solaire sur un parcours routier. L'objectif est de conna�tre
%  l'�tait de charge de la batterie (SoC) � la fin du trajet pour une
%  vitesse cible donn�e.
%  
%  Auteur : Julien Longchamp
%  Date de cr�ation : 17-06-2016
%  Derni�re modification : 07-07-2016 (JL)
%%

clc, clear all, close all

%% Importation des donn�es du circuit � r�aliser (Voir "traitementDonneesGPS.m")
% load('etapesASC2016_continuous.mat')
load('Data\ASC2016_stage3_plus_speed.mat')
parcours = newParcours;

%% V�rification de la pr�sence des limites de vitesse dans le fichier du parcours
contraintes.noSpeedLimit = 0;
try
    parcours.speed_limit;
catch E
    contraintes.noSpeedLimit = 1;
end

%% Charge tous les param�tres de la simulation5
run('Models/parameterGeneratorEclipseIX.m');

etat_course.index_depart = 13170; %round(0.47 * length(parcours.distance)); % D�part � un pourcentage du parcours
routeLog = routeSimulator(parcours, etat_course, cellModel, strategy, eclipse9, constantes, reglement, meteo);

routeLog.puissance_elec_traction(isnan(routeLog.puissance_elec_traction)) = 0;

for k = 1:length(routeLog)
    vitesse_moyenne(k) = mean(routeLog(k).profil_vitesse);
    puissance_moyenne(k) = mean(routeLog(k).puissance_elec_traction);
end

vitesse_moyenne_totale = mean(vitesse_moyenne);
puissance_moyenne_totale = mean(puissance_moyenne);

fprintf('\nHeure de d�part %s \n', datestr(etat_course.heure_depart));
fprintf('Heure finale %s \n', datestr(routeLog.heure_finale));
fprintf('Distance parcourue %3.2f km \n', parcours.distance(end)-parcours.distance(etat_course.index_depart));
fprintf('Vitesse moyenne %3.2f km/h \n', vitesse_moyenne_totale*3.6);
fprintf('Puissance moyenne %3.2f W \n', puissance_moyenne_totale);

h1 = figure;
hold on, grid on, title('FSGP 2016')
h2 = figure;
hold on, grid on, title('FSGP 2016')
temps_total = 0;
for k = 1:length(routeLog)
figure(h1)
plot(parcours.distance + (k-1)*parcours.distance(end), routeLog.puissance_elec_totale, 'b')
plot(parcours.distance + (k-1)*parcours.distance(end), routeLog.puissancePV, 'r')
plot(parcours.distance + (k-1)*parcours.distance(end), routeLog.puissance_moteurs, 'k')
plot(parcours.distance + (k-1)*parcours.distance(end), routeLog.SoC*1000, '--m')

figure(h2)
plot(parcours.distance + (k-1)*parcours.distance(end), routeLog.SoC*100, '--m')
plot(parcours.distance + (k-1)*parcours.distance(end), routeLog.profil_vitesse*3.6, 'g')
plot(parcours.distance + (k-1)*parcours.distance(end), parcours.speed_limit, 'r')

% plot(parcours.distance + (k-1)*parcours.distance(end), routeLog.profil_accel*36, 'r')

    temps_total = temps_total+routeLog.temps_cumulatif(end); 
end

figure(h1)
xlabel('distance (km)')
ylabel('puissance (W)')
legend('ELE', 'PV', 'MEC', 'SoC');
figure(h2)
xlabel('distance (km)')
legend('SoC', 'Vitesse (km/h)', 'Limite de vitesse');

nb_heures = temps_total/3600


% A = parcours.latitude;
% B = parcours.longitude;
% C = routeLog(1).puissance_elec_totale;
% D = routeLog(1).energie_fournie_totale ./ routeLog(1).Vbatt;
% E = routeLog(1).temps_cumulatif;
% save('dataTour50kmh.mat', 'A', 'B', 'C', 'D', 'E')


figure, hold on, title('Performance PV')
plot(routeLog.temps_cumulatif/3600, routeLog.puissancePV)
plot(routeLog.temps_cumulatif/3600, routeLog.SoC*100)

% figure, hold on, grid on
% plot(parcours.distance, parcours.altitude);

% figure, hold on, grid on
% plot3(parcours.longitude, parcours.latitude, parcours. altitude)

% figure, hold on, grid on
% plot(parcours.distance)