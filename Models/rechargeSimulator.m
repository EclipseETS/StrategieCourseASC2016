function [ SoC_out ] = rechargeSimulator(latitude, start_time, stop_time, meteo, SoC_in, cellModel)
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
%  Dernière modification :
%%


% Début de la recharge du soir jusqu'à ce que la batterie soit retirée de la voiture
temps_recharge = linspace(start_time, stop_time, 120); % Sépare la durée de la recharge en 120 points
delta_t = (temps_recharge(2) - temps_recharge(1)) * (24*60*60); % secondes Résolution temporelle pour la recharge de fin de journée (fraction de jour /(24*60*60) = secondes)
energie_recuperee = 0; % J
avecSupport = 1;
index_meteo = 1;
for r = 1:length(temps_recharge)
    %             densite_de_puissance_incidente2 = polyval(constantes.irrandiance_coef, mod(temps_recharge_soir(r),1)*24); % Calcul de la densite de puissance incidente
    densite_de_puissance_incidente = solarradiationInstant(zeros(2), ones(1,2)*latitude,1,0.2,temps_recharge(r)); % solarradiationInstant(dem,lat,cs,r, currentDate) Voir le fichier solarradiationInstant.m
    [puissancePV(r) Elevation(r)] = solarArrayModel(temps_recharge(r), densite_de_puissance_incidente, avecSupport, meteo.sun_cycle_coef);

    puissancePV_reel(r) = -meteo.couverture_ciel(index_meteo) * puissancePV(r); % W
    energie(r) = puissancePV_reel(r) * delta_t; % Joules
    energie_recuperee = energie_recuperee + puissancePV_reel(r) * delta_t; % Joules    
end

energie_recuperee_wh = energie_recuperee/3600; % Wh Énergie récupérée totale durant l'arrêt
SoC_Ah = 3.35 * (1-SoC_in);    % Ah      % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
Ebatt = 38 * polyval(cellModel.decharge0C2, SoC_Ah); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C
new_SoC_Ah = SoC_Ah - (energie_recuperee_wh/Ebatt/11); % ************ TODO : REMOVE THE MAGIC NUMBERS ************ !!!!!!!!!!!! MAGIC NUMBERS ALERT !!!!!!!!!!!!
new_SoC_Ah = max([new_SoC_Ah, 0]);
new_SoC_Ah = min([new_SoC_Ah, 3.35]);
SoC_out = (3.35 - new_SoC_Ah) / 3.35;

end

