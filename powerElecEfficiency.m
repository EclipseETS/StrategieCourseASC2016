function [efficiencyMotors, efficiencyDrive, batteryEfficiency, outTempWinding] = powerElecEfficiency(actualTorque, radSpeed, tempAmbiant, tempWinding, SoC, cellModel)

%% Éclipse 9
%  powerElecEfficiency.m
%  Permet de calculer l'efficacité de la chaîne de traction de la voiture solaire Éclipse 9
%  
%  Les paramètres proviennent du document Application Notes pour un moteur
%  Marand (CSiro)
%
%  Auteur : Julien Longchamp
%  Date de création : 03-03-2016
%  Dernière modification :
%%

%% Paramètres du moteur Marand (CSiro)
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
torqueUnmoteur = actualTorque/2;    % Nm
tempMagnet = 0.5*(tempAmbiant + tempWinding); % K
magnetB = 1.32-(1.2e-3)*(tempMagnet-293);  % T
phCurrentRMS = 0.561.*magnetB.*torqueUnmoteur; % Arms
windingRes = 0.0575*(1+0.0039*(tempWinding-293)); % ohm
copperLoss = 3*phCurrentRMS.^2*windingRes; % W
eddyCurrentLoss = ((9.602e-6).*(magnetB.*radSpeed).^2)./windingRes; % W
windingLoss = (170.4e-6).*radSpeed.^2; % W
outTempWinding = 0.455*(windingLoss + eddyCurrentLoss) + tempAmbiant; % K
mecPowerDeuxMoteurs = actualTorque.*radSpeed;   % W
totalMotorsInputPower = mecPowerDeuxMoteurs+2*(copperLoss+eddyCurrentLoss+windingLoss); % W
efficiencyMotors = mecPowerDeuxMoteurs./ totalMotorsInputPower; % Percent


%% Modèle de la batterie
%load('Eclipse9_cells_discharge.mat', 'p1', 'p2', 'p3'); % Importation des courbes de décharge des batteries
decharge0C2 = cellModel.decharge0C2;
decharge1C = cellModel.decharge1C;
decharge2C = cellModel.decharge2C;

nb_cell_serie = 38;
nb_cell_para = 11;
nb_cell_total = nb_cell_serie*nb_cell_para;

Ecell_max = 4.2;    % V
Ecell_min = 2.6;    % V
Ccell = 3.35;       % Ah
Crate_max = 2;
Rcell = 0.125;      % ohm (NRC18560B from http://lygte-info.dk/review/batteries2012/Common18650Summary%20UK.html) 

Ebatt_max = Ecell_max*nb_cell_serie;
Ibatt_max = Crate_max*Ccell*nb_cell_para;   % Courant de la batterie à 2 C
Ibatt_nom = Ccell*nb_cell_para;             % Courant de la batterie à 1 C

Battery_capacity = Ccell*nb_cell_total;     % kWh
Rint = nb_cell_serie/nb_cell_para*Rcell;    % ohm

capacite_restante = Ccell * (1-SoC);    % Ah
Ebatt = nb_cell_serie*polyval(decharge0C2, capacite_restante); % V (Tension E0 instantanée du batterie pack obtenue sur la courbe 0,2C

Drive_efficiency_estimation = 0.95;
Pbatt_estimee = totalMotorsInputPower ./ Drive_efficiency_estimation;
Ibatt = zeros(size(Pbatt_estimee));
for k=1:length(Pbatt_estimee)
    Ibatt(k) = max(roots([-Rint, Ebatt(k), Pbatt_estimee(k)]));  
    if isreal(Ibatt(k)) == 0
        disp('FUCK')
    end
end

Vbus = Ebatt-Rint.*Ibatt;   % V

batteryLoss = Rint.*Ibatt.^2;   % W
batteryPower = Ebatt.*Ibatt;    % W
batteryEfficiency = (batteryPower - batteryLoss) ./ batteryPower;   % (%)

%% Modèle de l'onduleur Tritium WaveSculptor22
%Vbus = 150; % V ********************** TO DO : Remplacer par le modèle de la batterie *******************************

alpha = 3.3450E-3; % linear component of the switching loss (per unit of bus voltage)
beta = 1.8153E-2; % constant component of the switching loss (per unit of bus voltage)
Cfeq = 1.5625E-4; % (F) equivalent capacitance*frequency product of the entire controller
Req = 1.0800E-2; % (ohm) equivalent resistance of the entire controller

driveLoss = Req.*phCurrentRMS.^2 +(alpha.*phCurrentRMS+beta).*Vbus + Cfeq.*Vbus.^2; % W
driveInputPower = totalMotorsInputPower+driveLoss;    % W
efficiencyDrive = totalMotorsInputPower./driveInputPower; % (%)
if efficiencyDrive < 0.1
    disp('CACA')
end

