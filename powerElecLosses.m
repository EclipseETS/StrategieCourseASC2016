function [motorsLosses, drivesLosses, batteryLosses, outTempWinding] = powerElecLosses(actualTorque, radSpeed, tempAmbiant, tempWinding, SoC, cellModel)

%% �clipse 9
%  powerElecEfficiency.m
%  Permet de calculer les pertes de chaque �l�ment de la cha�ne de traction de la voiture solaire �clipse 9
%  
%  Les param�tres proviennent du document Application Notes pour un moteur
%  Marand (CSiro)
%
%  Auteur : Julien Longchamp
%  Date de cr�ation : 03-03-2016
%  Derni�re modification :
%%

%% Param�tres du moteur Marand (CSiro) provenant du document "Application Notes"
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

% Mod�le Steady-State
%tempAmbiant = 300; % K initial value (27�C)
%tempWinding = 300; % K initial value (27�C)
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

%% Mod�le de la batterie
%load('Eclipse9_cells_discharge.mat', 'p1', 'p2', 'p3'); % Importation des courbes de d�charge des batteries
decharge0C2 = cellModel.decharge0C2;    % Courbe de d�charge � 0.2 C  =~ 7.37  Adc
decharge1C = cellModel.decharge1C;      % Courbe de d�charge � 1 C    =~ 36.85 Adc
decharge2C = cellModel.decharge2C;      % Courbe de d�charge � 2 C    =~ 73.70 Adc

% Configuration du battery pack
nb_cell_serie = 38;
nb_cell_para = 11;
nb_cell_total = nb_cell_serie*nb_cell_para;

% Propri�t�s des cellules NRC18650B
Ecell_max = 4.2;    % V
Ecell_min = 2.6;    % V
Ccell = 3.35;       % Ah
Crate_max = 2;
Rcell = 0.125;      % ohm (NRC18560B from http://lygte-info.dk/review/batteries2012/Common18650Summary%20UK.html) 

% Calcul des param�tres de la batterie
Ebatt_max = Ecell_max*nb_cell_serie;
Ibatt_max = Crate_max*Ccell*nb_cell_para;   % Courant de la batterie � 2 C
Ibatt_nom = Ccell*nb_cell_para;             % Courant de la batterie � 1 C
Battery_capacity = Ccell*nb_cell_total;     % kWh
Rint = nb_cell_serie/nb_cell_para*Rcell;    % ohm

% Calcul de la capacit� restante et de la tension actuelle de la batterie
capacite_restante = Ccell * (1-SoC);    % Ah
Ebatt = nb_cell_serie*polyval(decharge0C2, capacite_restante); % V (Tension E0 instantan�e du batterie pack obtenue sur la courbe 0,2C

% Calcul des pertes dans la batterie
Drive_efficiency_estimation = 0.95; % (%)
Pbatt_estimee = totalMotorsInputPower ./ Drive_efficiency_estimation;   % W     % Estimation de la puissance fournie de la batterie en possant l'efficacit� de la drive � 95%
Ibatt = Pbatt_estimee/Ebatt;    % A
Vbus = Ebatt-Rint.*Ibatt;       % V

batteryLosses = Rint.*Ibatt.^2;   % W
batteryPower = Ebatt.*Ibatt;    % W
batteryEfficiency = (batteryPower - batteryLosses) ./ batteryPower;   % (%)

%% Mod�le de l'onduleur Tritium WaveSculptor22
%Vbus = 150; % V ********************** TO DO : Remplacer par le mod�le de la batterie *******************************

alpha = 3.3450E-3; % linear component of the switching loss (per unit of bus voltage)
beta = 1.8153E-2; % constant component of the switching loss (per unit of bus voltage)
Cfeq = 1.5625E-4; % (F) equivalent capacitance*frequency product of the entire controller
Req = 1.0800E-2; % (ohm) equivalent resistance of the entire controller

drivesLosses = 2*(Req.*phCurrentRMS.^2 +(alpha.*3.*phCurrentRMS+beta).*Vbus + Cfeq.*Vbus.^2); % W    % **** TODO : V�rifier s'il faut bien multiplier le courant de phase par 3 -> 3.*phCurrentRMS
drivesInputPower = totalMotorsInputPower+drivesLosses;    % W
efficiencyDrive = totalMotorsInputPower./drivesInputPower; % (%)


