function [motorsLosses, drivesLosses, batteryLosses, outTempWinding, Ibatt] = powerElecLosses(actualTorque, radSpeed, tempAmbiant, tempWinding, SoC, cellModel, eclipse9)

%% Éclipse 9
%  powerElecEfficiency.m
%  Permet de calculer les pertes de chaque élément de la chaîne de traction de la voiture solaire Éclipse 9
%  
%  Les paramètres proviennent du document Application Notes pour un moteur
%  Marand (CSiro) 
%
% http://lati-solar-car.wikispaces.com/file/view/Solar+Car+Wheel+Motor+Information+Sheet.pdf
%
%  Auteur : Julien Longchamp
%  Date de création : 03-03-2016
%  Dernière modification :

%% Paramètres du moteur Marand (CSiro) provenant du document "Application Notes"
% numPoles = 40;
% numPolesPairs = numPoles/2;
% numPhases = 3;
% motorWheelMass = 13; % kg (Include the whole wheel assembly) TO BE VERIFIED
% nomSpeed = 111;     % rad/s
% nomTorque = 16.2;   % Nm
% airGap = 0.00175;   % m
% phasesRes = 0.0575; % ohm
% kV = 0.45;          % Vs/rad  EMF constant
% kA = 0.44;          % Nm/A    Torque constant per phase
% inductorMass = 1.11; % kg
% inductorRes = 0.00627; % ohm
% inductorVal = 95e-6; % H

% Modèle Steady-State
%tempAmbiant = 300; % K initial value (27°C)
%tempWinding = 300; % K initial value (27°C)
mecPowerDeuxMoteurs = actualTorque.*radSpeed;   % W
torqueUnmoteur = actualTorque/2;    % Nm
tempMagnet = 0.5*(tempAmbiant + tempWinding); % K
magnetB = 1.32-(1.2e-3)*(tempMagnet-293);  % T
phCurrentRMS = 0.561.*magnetB.*torqueUnmoteur; % Arms
windingRes = 0.0575*(1+0.0039*(tempWinding-293)); % ohm
copperLoss = 3*phCurrentRMS.^2*windingRes; % W
eddyCurrentLoss = ((9.602e-6).*(magnetB.*radSpeed).^2)./windingRes; % W
windingLoss = (170.4e-6).*radSpeed.^2; % W
outTempWinding = 0.455*(windingLoss + eddyCurrentLoss) + tempAmbiant; % K

totalMotorsInputPower = mecPowerDeuxMoteurs+2*(copperLoss+eddyCurrentLoss+windingLoss); % W
efficiencyMotors = mecPowerDeuxMoteurs./ totalMotorsInputPower; % Percent
motorsLosses = 2*(copperLoss+eddyCurrentLoss+windingLoss);

%% Modèle de la batterie
%load('Eclipse9_cells_discharge.mat', 'p1', 'p2', 'p3'); % Importation des courbes de décharge des batteries
decharge0C2 = cellModel.decharge0C2;    % Courbe de décharge à 0.2 C  =~ 7.37  Adc
decharge1C = cellModel.decharge1C;      % Courbe de décharge à 1 C    =~ 36.85 Adc
decharge2C = cellModel.decharge2C;      % Courbe de décharge à 2 C    =~ 73.70 Adc

% Configuration du battery pack
nb_cell_serie = eclipse9.nb_cell_serie;
nb_cell_para = eclipse9.nb_cell_para;
nb_cell_total = eclipse9.nb_cell_total;

% Propriétés des cellules NRC18650B
Ecell_max = eclipse9.Ecell_max;    % V
Ecell_min = eclipse9.Ecell_min;    % V
Ccell = eclipse9.Ccell;       % Ah
Crate_max = eclipse9.Crate_max;
Rcell = eclipse9.Rcell;      % ohm (NRC18560B from http://lygte-info.dk/review/batteries2012/Common18650Summary%20UK.html) 

% Calcul des paramètres de la batterie
Ebatt_max = eclipse9.Ebatt_max ;
Ibatt_max = eclipse9.Ibatt_max;   % Courant de la batterie à 2 C
Ibatt_nom = eclipse9.Ibatt_nom;             % Courant de la batterie à 1 C
Battery_capacity = eclipse9.Battery_capacity;     % kWh
Rint = eclipse9.Rint;    % ohm

% Calcul de la capacité restante et de la tension actuelle de la batterie
capacite_restante = Ccell * (1-SoC);    % Ah
Ebatt = nb_cell_serie*polyval(decharge0C2, capacite_restante); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C

% Calcul des pertes dans la batterie
Drive_efficiency_estimation = 0.95; % (%)
Pbatt_estimee = totalMotorsInputPower ./ Drive_efficiency_estimation;   % W     % Estimation de la puissance fournie de la batterie en possant l'efficacité de la drive à 95%
Ibatt = Pbatt_estimee/Ebatt;    % A
Vbus = Ebatt-Rint.*Ibatt;       % V

batteryLosses = Rint.*Ibatt.^2;   % W
batteryPower = Ebatt.*Ibatt;    % W
batteryEfficiency = (batteryPower - batteryLosses) ./ batteryPower;   % (%)

%% Modèle de l'onduleur Tritium WaveSculptor22
%Vbus = 150; % V ********************** TO DO : Remplacer par le modèle de la batterie *******************************

alpha = 3.3450E-3; % linear component of the switching loss (per unit of bus voltage)
beta = 1.8153E-2; % constant component of the switching loss (per unit of bus voltage)
Cfeq = 1.5625E-4; % (F) equivalent capacitance*frequency product of the entire controller
Req = 1.0800E-2; % (ohm) equivalent resistance of the entire controller

drivesLosses = 2*(Req.*phCurrentRMS.^2 +(alpha.*3.*phCurrentRMS+beta).*Vbus + Cfeq.*Vbus.^2); % W    % **** TODO : Vérifier s'il faut bien multiplier le courant de phase par 3 -> 3.*phCurrentRMS
drivesInputPower = totalMotorsInputPower+drivesLosses;    % W
efficiencyDrive = totalMotorsInputPower./drivesInputPower; % (%)


