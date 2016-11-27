%% Éclipse 9
%  Le script course_sur_circuit.m permet de simuler la performance d'une
%  voiture solaire sur un parcours sur circuit. L'objectif est de connaître
%  le nombre de tours que le véhicule peut réaliser en respectant la
%  capacité de la batterie.mn
%  
%  Auteur : Julien Longchamp
%  Date de création : 17-06-2016
%  Dernière modification : 07-07-2016 (JL)
%%

clc, clear all, close all

%% Importation des données du circuit à réaliser (Voir "traitementDonneesGPS.m")
%load('etapesASC2016_continuous.mat')
% load('TrackPMGInner10m.mat')
load('C:\Users\club\Git\StrategieCourseASC2016\PittRaceNorthTrack10m.mat')
parcours = newParcours;

%% Charge tous les paramètres de la simulation
run('parameterGeneratorEclipseIX.m');

%% Simulation des tours de piste
nbLapMax = 485;%ceil(485 / parcours.distance(end)); % 485 km / longueur d'un tour
outOfFuel = 0;
while outOfFuel == 0 && etat_course.nbLap < nbLapMax
    etat_course.nbLap = etat_course.nbLap+1;
    lapLog(etat_course.nbLap) = lapSimulator(parcours, etat_course, cellModel, contraintes, eclipse9, constantes);
    
    etat_course.SoC_start = lapLog(etat_course.nbLap).SoC(end);    
    etat_course.vitesse_ini = lapLog(etat_course.nbLap).profil_vitesse(end);
    
    if mod(lapLog(etat_course.nbLap).heure_finale,1) > 0.7292
        disp('Fin de la journée')
        etat_course.heure_depart = datenum([2016,07,04,8,30,0]);
    else
        etat_course.heure_depart = lapLog(etat_course.nbLap).heure_finale;
    end
    outOfFuel = lapLog(etat_course.nbLap).outOfFuel;  
    
end

for k = 1:length(lapLog)
    vitesse_moyenne(k) = mean(lapLog(k).profil_vitesse);
    puissance_moyenne(k) = mean(lapLog(k).puissance_elec_traction);
end
vitesse_moyenne_totale = mean(vitesse_moyenne);
puissance_moyenne_totale = mean(puissance_moyenne);

fprintf('\nLa voiture s''est arrêtée après %3d tours \n', etat_course.nbLap);
fprintf('Distance parcourue %3.2f km \n', etat_course.nbLap*parcours.distance(end));
fprintf('Vitesse moyenne %3.2f km/h \n', vitesse_moyenne_totale*3.6);
fprintf('Puissance moyenne %3.2f W \n', puissance_moyenne_totale);

h1 = figure;
hold on, grid on, title('FSGP 2016')
h2 = figure;
hold on, grid on, title('FSGP 2016')
for k = 1:length(lapLog)
figure(h1)
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissance_elec_totale, 'b')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissancePV, 'r')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissance_moteurs, 'k')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).SoC*1000, '--m')

figure(h2)
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).SoC*100, '--m')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).profil_vitesse*3.6, 'g')
plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).profil_accel*36, 'r')

end

figure(h1)
xlabel('distance (km)')
ylabel('puissance (W)')
legend('ELE', 'PV', 'MEC', 'SoC');
figure(h2)
xlabel('distance (km)')
legend('SoC', 'Vitesse (km/h)', 'Accel (10 km/h^2)');

A = parcours.latitude;
B = parcours.longitude;
C = lapLog(1).puissance_elec_totale;
D = lapLog(1).energie_fournie_totale ./ lapLog(1).Vbatt;
E = lapLog(1).temps_cumulatif;
save('dataTour50kmh.mat', 'A', 'B', 'C', 'D', 'E')


