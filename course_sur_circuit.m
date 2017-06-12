%% eclipse 9
%  Le script course_sur_circuit.m permet de simuler la performance d'une
%  voiture solaire sur un parcours sur circuit. L'objectif est de connaetre
%  le nombre de tours que le vehicule peut realiser en respectant la
%  capacite de la batterie.mn
%
%  Auteur : Julien Longchamp
%  Date de creation : 17-06-2016
%  Dernieres modifications : 01-04-2017 (JL)
%                            13-01-2017 (JL) Redaction du guide de l'utilisateur
%                            07-07-2016 (JL)
%%

clc, clear all, close all

%% Ajoute les repertoires necessaires au chemin de recherchclce du projet
addpath('Data');
addpath('Models');
addpath('Outils');

%% Importation des donnees du circuit desire (Voir "traitementDonneesGPS.m")
%load('Data/ASC2016_stage3_plus_speed.mat')
load('FSGP2017_CircuitOfTheAmericas10m.mat')
parcours = newParcours;

%% Charge tous les parametres de la simulation
run('Models/parameterGeneratorEclipseIX.m');


%% Simulation des tours de piste
nbLapMax = ceil(485 / parcours.distance(end)); % 485 km / longueur d'un tour
outOfFuel = 0; % Flag qui tombe à 1 lorsque la batterie est à plat
journee = 3;
while outOfFuel == 0 && etat_course.nbLap < nbLapMax
    etat_course.nbLap = etat_course.nbLap+1;
    lapLog(etat_course.nbLap) = lapSimulator(parcours, etat_course, cellModel, strategy, eclipse9, constantes, reglement, meteo);
    
    etat_course.SoC_start = lapLog(etat_course.nbLap).SoC(end);
    etat_course.vitesse_ini = lapLog(etat_course.nbLap).profil_vitesse(end);
    
    if journee < 3 && (mod(lapLog(etat_course.nbLap).heure_finale,1) > reglement.heure_arret || lapLog(etat_course.nbLap).outOfFuel)
        disp('Fin de la journee')
        journee = journee + 1;
        etat_course.heure_depart = datenum([2016,07,26,10,0,0]);
        etat_course.vitesse_ini = 0;
        
        [SoC_out_soir] = rechargeSimulator(parcours.latitude(1), lapLog(etat_course.nbLap).heure_finale, reglement.impound_in, meteo, lapLog(etat_course.nbLap).SoC(end), cellModel);
        [SoC_out_matin] = rechargeSimulator(parcours.latitude(1), reglement.impound_out, reglement.fsgp_fin_recharge_matin, meteo, SoC_out_soir, cellModel);
        etat_course.SoC_start = SoC_out_matin;     
        disp(['SoC recharge e : ' num2str(SoC_out_matin*100) '%'])
    else
        etat_course.heure_depart = lapLog(etat_course.nbLap).heure_finale;
        outOfFuel = lapLog(etat_course.nbLap).outOfFuel;
    end
    
    if mod(lapLog(etat_course.nbLap).heure_finale,1) > reglement.heure_arret || lapLog(etat_course.nbLap).outOfFuel
        outOfFuel = 1;
        disp(datestr(lapLog(etat_course.nbLap).heure_finale));
    end
    
end

for k = 1:length(lapLog)-1
    vitesse_moyenne(k) = mean(lapLog(k).profil_vitesse);
    puissance_moyenne(k) = mean(lapLog(k).puissance_elec_traction);
    puissancePV_moyenne(k) = mean(lapLog(k).puissancePV);
end
% Dernier tour
if length(lapLog) == 1; k = 0; end
vitesse_moyenne(k+1) = mean(lapLog(end).profil_vitesse(1:lapLog(end).indexArret));
puissance_moyenne(k+1) = mean(lapLog(end).puissance_elec_traction(1:lapLog(end).indexArret));
puissancePV_moyenne(k+1) = mean(lapLog(end).puissancePV(1:lapLog(end).indexArret));
    
vitesse_moyenne_totale = mean(vitesse_moyenne);
puissance_moyenne_totale = mean(puissance_moyenne);
puissancePV_moyenne_totale = mean(puissancePV_moyenne);

temps_total = lapLog(k).temps_cumulatif(end)

fprintf('\nLa voiture s''est arretee apres %3d tours \n', etat_course.nbLap);
fprintf('Distance parcourue %3.2f km \n', (etat_course.nbLap-1)*parcours.distance(end)+parcours.distance(lapLog(end).indexArret));
fprintf('Vitesse moyenne %3.2f km/h \n', vitesse_moyenne_totale*3.6);
fprintf('Puissance moyenne %3.2f W \n', puissance_moyenne_totale);
fprintf('Puissance PV moyenne %3.2f W \n', puissancePV_moyenne_totale);
fprintf('SoC début/fin %3.2f  /  %3.2f \n', strategy.SoC_ini, lapLog(end).SoC(end));
fprintf('Nombre d''heures %3.2f \n', temps_total/3600);

%% Display figures
% h1 = figure;
% hold on, grid on, title('evolution de la puissance')
% h2 = figure;
% hold on, grid on, title('Évolution de l''''état de charge')
% h3 = figure;
% hold on, grid on, title('Performance du systeme PV')
% temps_total = 0;
% for k = 1:length(lapLog)
%     if k == length(lapLog)
%         m = lapLog.indexArret;
%     else
%         m = length(parcours.distance);
%     end
%     figure(h1)
%     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).puissance_elec_totale(1:m), '.b')
%     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).puissancePV(1:m), 'dr')
%     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).puissance_moteurs(1:m), '.k')
%     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).SoC(1:m)*1000, '--m')
%     
%     figure(h2)
% %     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).SoC(1:m)*100, '--m')
% %     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).profil_vitesse(1:m), 'g')
% %     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).profil_accel(1:m), 'r')
% %     plot(parcours.distance(1:m) + (k-1)*parcours.distance(end), lapLog(k).puissancePV(1:m)/100, '.b')
%     
%     % Passe de pirate pour faire des graphiques pour ENR889
%     subplot(2,1,1), hold on
%     plot(parcours.distance(1:m), parcours.altitude(1:m))
%     subplot(2,1,2), hold on
%     temps = lapLog(k).temps_cumulatif(1:m)/3600;
%     plot(temps, lapLog(k).profil_vitesse(1:m)*3.6/65, '.g','MarkerSize',1)
%     plot(temps, lapLog(k).SoC(1:m), '--m')
%     plot(temps, lapLog(k).puissancePV(1:m)/1000, '--r')
% 
%     figure(h3)
%     plot(lapLog(k).temps_cumulatif, lapLog(k).puissancePV);
%     temps_total = temps_total+lapLog(k).temps_cumulatif(end);    
% end
% 
% % figure
% % plot(lapLog(k).temps_cumulatif, lapLog(k).puissancePV)
% 
% figure(h1)
% xlabel('distance (km)')
% ylabel('puissance (W)')
% legend('ELE', 'PV', 'MEC', 'SoC');
% figure(h2)
% xlabel('Temps (h)')
% legend( 'Vitesse normalisée', 'État de charge (%)', 'Puissance PV (kW)');




% A = parcours.latitude;
% B = parcours.longitude;
% C = lapLog(1).puissance_elec_totale;
% D = lapLog(1).energie_fournie_totale ./ lapLog(1).Vbatt;
% E = lapLog(1).temps_cumulatif;
% save('dataTour50kmh.mat', 'A', 'B', 'C', 'D', 'E')


% figure, hold on, title('Test')
% [hAx,hLine1,hLine2] = plotyy(lapLog(k).temps_cumulatif(1:m)/3600,lapLog(k).SoC(1:m),lapLog(k).temps_cumulatif(1:m)/3600, lapLog(k).puissancePV(1:m));
% % plot(lapLog(k).temps_cumulatif, lapLog(k).temps_cumulatif.profil_vitesse(1:m)*3.6);
% xlabel('Temps')
% ylabel(hAx(1),'State of Charge %') % left y-axis
% ylabel(hAx(2),'Puissance PV (W)') % right y-axis