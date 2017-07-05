function [ SoC_out ] = rechargeSimulator(etat_course, start_time, stop_time, meteo, SoC_in, cellModel, eclipse9)
%% Éclipse 9
%  La fonction rechargeSimulator permet de simuler une recharge des panneaux solaires durant un interval de temps déterminé.
%
%  Entrées :
%    * start_time
%    * stop_time
%    * latitude
%    * longitude
%    * altitude
%    * meteo
%    * SoC_in
%    * cellModel -> Modèles de la batterie
%
%
%  Sorties :
%    * SoC_out -> State of charge de la batterie après la recharge (%)
%
%  Auteur : Julien Longchamp
%  Date de création : 17-06-2016
%  Dernière modification : 04-07-2017 Mégane Lavallee
%%

% Début de la recharge du soir jusqu'à ce que la batterie soit retirée de la voiture
% temps_recharge = linspace(start_time, stop_time, 120); % Sépare la durée de la recharge en 120 points
stop_time = stop_time * 24;
start_time = start_time * 24;
demi_heure = ((stop_time - start_time)/.5);
temps_recharge = start_time:0.5:stop_time; % Sépare la durée de la recharge en 30 points (30
temps_recharge = temps_recharge (1,2:end);
delta_t = 1800; % secondes, car c'est calculer a chaque 30 minutes
% temps_recharge = ceil((stop_time - start_time)/.5)*.5 ; % Heure arrondie aux 30 minutes; Sépare la durée de la recharge en 30 minutes

% delta_t = (temps_recharge(2) - temps_recharge(1)) * (24*60*60); % secondes Résolution temporelle pour la recharge de fin de journée (fraction de jour /(24*60*60) = secondes)
energie_recuperee = 0; % J
% avecSupport = 1;
% index_meteo = 1;

for r = 1:length(temps_recharge)
   %%   
    warning ('off')
      
    heureArrondieVec = [floor(temps_recharge(r)) mod(temps_recharge (r),1)*60 0];
    lapDateVec = datevec(etat_course.heure_depart, 'yyyy-mm-dd HH:MM:SS');
    lapTimeVec = datevec(datenum([lapDateVec(1:3) heureArrondieVec]), 'yyyy-mm-dd HH:SS:MM');
    
    indexPV = find(ismember (meteo.dateVec_irradiance, lapTimeVec, 'rows'));
    
    if isempty (indexPV) == 1
        error ('IndexPV ne doit pas etre egal a zero')
    end
    
    irrandiance = meteo.direct_irradiance(1 , indexPV);
    puissancePV(r) = irrandiance * eclipse9.SurfaceTotalePV * eclipse9.EfficaciteSunPowerBinH; %W
    warning ('on')
 %%   
    
%     densite_de_puissance_incidente2 = polyval(constantes.irrandiance_coef, mod(temps_recharge_soir(r),1)*24); % Calcul de la densite de puissance incidente
%     densite_de_puissance_incidente = solarradiationInstant(zeros(2), ones(1,2)*latitude,1,0.2,temps_recharge(r)); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
%     [puissancePV(r) Elevation(r)] = solarArrayModel(temps_recharge(r), densite_de_puissance_incidente, avecSupport, meteo.sun_cycle_coef);

%     puissancePV_reel(r) = -meteo.couverture_ciel(index_meteo) * puissancePV(r); % W
%     energie(r) = puissancePV(r) * delta_t; % Joules
    energie_recuperee = energie_recuperee + puissancePV(r) * delta_t ; % Joules (1 W*s = 1 J)   
end
energie_recuperee_wh = energie_recuperee/3600; % Wh Énergie récupérée totale durant l'arrêt
% disp (energie_recuperee_wh/1000)
SoC_Ah = eclipse9.Ccell * (1-SoC_in);    % Ah      
Ebatt = 38 * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
new_SoC_Ah = SoC_Ah - (energie_recuperee_wh/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
new_SoC_Ah = max([new_SoC_Ah, 0]);
new_SoC_Ah = min([new_SoC_Ah, eclipse9.Ccell]);
SoC_out = (eclipse9.Ccell - new_SoC_Ah) / eclipse9.Ccell;

end

