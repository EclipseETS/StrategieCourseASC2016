%% Eclipse 9
%  Le script course_sur_circuit.m permet de simuler la performance d'une
%  voiture solaire sur un parcours sur circuit. L'objectif est de connaitre
%  le nombre de tours que le vehicule peut realiser en respectant la
%  capacite de la batterie.mn
%
%  Auteur : Julien Longchamp
%  Date de creation : 17-06-2016
%  Dernieres modifications : 13-01-2017 (JL) Redaction du guide de l'utilisateur
%                            07-07-2016 (JL)
%%

clear all, close all, clc

%% Ajoute les repertoires necessaires au chemin de recherche du projet
addpath('Data');
addpath('Models');
addpath('Outils');

%% Importation des donnees du circuit a realiser (Voir "traitementDonneesGPS.m")
% load('etapesASC2016_continuous.mat')
% load('TrackPMGInner10m.mat')
% load('Data/TrackPMGInner10m.mat') % Octave
% load('PittRaceNorthTrack10m.mat')
% parcours = newParcours;

%% Charge tous les parametres de la simulation
run('parameterGeneratorEclipseIX.m');


%% Simulation des tours de piste
nbLapMax = etat_course.nbLapMax; %ceil(485 / parcours.distance(end)); % 485 km / longueur d'un tour
outOfFuel = 0; % Flag qui tombe a 1 lorsque la batterie est a plat
journee = etat_course.journee;
while outOfFuel == 0 && etat_course.nbLap < nbLapMax
    etat_course.nbLap = etat_course.nbLap+1;
    lapLog(etat_course.nbLap) = lapSimulator2017(newParcours, etat_course, cellModel, strategy, eclipse9, constantes, reglement, meteo);
    
    etat_course.SoC_start = lapLog(etat_course.nbLap).SoC(end);
    etat_course.vitesse_ini = lapLog(etat_course.nbLap).profil_vitesse(end);
    
    if journee < 3 && (mod(lapLog(etat_course.nbLap).heure_finale,1) > reglement.heure_arret || lapLog(etat_course.nbLap).outOfFuel)
        disp('Fin de la journee')
        journee = journee + 1;
        etat_course.heure_depart = datenum([2017,06,17,reglement.heure_depart*24,0,0]);
        etat_course.vitesse_ini = 0;
        
        [SoC_out_soir] = rechargeSimulator(newParcours.latitude(1), lapLog(etat_course.nbLap).heure_finale, reglement.impound_in, meteo, lapLog(etat_course.nbLap).SoC(end), cellModel);
        [SoC_out_matin] = rechargeSimulator(newParcours.latitude(1), reglement.impound_out, reglement.fsgp_fin_recharge_matin, meteo, SoC_out_soir, cellModel);
        etat_course.SoC_start = SoC_out_matin;     
        disp(['SoC recharger : ' num2str(SoC_out_matin*100) '%'])
    else
        etat_course.heure_depart = lapLog(etat_course.nbLap).heure_finale;
        outOfFuel = lapLog(etat_course.nbLap).outOfFuel;
    end
    
    if mod(lapLog(etat_course.nbLap).heure_finale,1) > reglement.heure_arret || lapLog(etat_course.nbLap).outOfFuel
        outOfFuel = 1;
        disp(datestr(lapLog(etat_course.nbLap).heure_finale));
    end
    
end

for nb_de_tours = 1:length(lapLog)
    vitesse_moyenne(nb_de_tours) = mean(lapLog(nb_de_tours).profil_vitesse);
    puissance_moyenne(nb_de_tours) = mean(lapLog(nb_de_tours).puissance_elec_traction);
    puissancePV_moyenne(nb_de_tours) = mean(lapLog(nb_de_tours).puissancePV);
end
vitesse_moyenne_totale = mean(vitesse_moyenne);
puissance_moyenne_totale = mean(puissance_moyenne);
puissancePV_moyenne_totale = mean(puissancePV_moyenne);

fprintf('\nLa voiture s''est arretee apres %3d tours \n', etat_course.nbLap);
fprintf('Distance parcourue %3.2f km \n', etat_course.nbLap*newParcours.distance(end));
fprintf('Vitesse moyenne %3.2f km/h \n', vitesse_moyenne_totale*3.6);
fprintf('Puissance moyenne %3.2f W \n', puissance_moyenne_totale);
fprintf('Puissance PV moyenne %3.2f W \n', puissancePV_moyenne_totale);

% h1 = figure;
% hold on, grid on, title('Evolution de la puissance')
% h2 = figure;
% hold on, grid on, title('Evolution de l''''etat de charge')
% for k = 1:length(lapLog)
%     figure(h1)
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissance_elec_totale, '.b')
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissancePV, 'dr')
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).puissance_moteurs, '.k')
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).SoC*1000, '--m')
%     
%     figure(h2)
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).SoC*100, '--m')
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).profil_vitesse*3.6, 'g')
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).profil_accel*36, 'r')
%     plot(parcours.distance + (k-1)*parcours.distance(end), lapLog(k).elevation, '.b')
% end
% 
% figure(h1)
% xlabel('distance (km)')
% ylabel('puissance (W)')
% legend('ELE', 'PV', 'MEC', 'SoC');
% figure(h2)
% xlabel('distance (km)')
% legend('SoC', 'Vitesse (km/h)', 'Accel (10 km/h^2)');

% A = parcours.latitude;
% B = parcours.longitude;
% C = lapLog(1).puissance_elec_totale;
% D = lapLog(1).energie_fournie_totale ./ lapLog(1).Vbatt;
% E = lapLog(1).temps_cumulatif;
% save('dataTour50kmh.mat', 'A', 'B', 'C', 'D', 'E')

