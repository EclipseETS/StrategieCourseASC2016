function [efficiencyMotor, efficiencyDrive, outTempWinding] = motorEfficiency(actualTorque, radSpeed, tempAmbiant, tempWinding)

%% Éclipse 9
%  Modèle du moteur
%  Permet de calculer l'efficacité du moteur CSiro pour un point
%  d'opération précis
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
tempMagnet = 0.5*(tempAmbiant + tempWinding); % K
magnetB = 1.32-(1.2e-3)*(tempMagnet-293);  % T
phCurrentRMS = 0.561.*magnetB.*actualTorque; % Arms
windingRes = 0.0575*(1+0.0039*(tempWinding-293)); % ohm
copperLoss = 3*phCurrentRMS.^2*windingRes; % W
eddyCurrentLoss = ((9.602e-6).*(magnetB.*radSpeed).^2)./windingRes; % W
windingLoss = (170.4e-6).*radSpeed.^2; % W
outTempWinding = 0.455*(windingLoss + eddyCurrentLoss) + tempAmbiant; % K
mecPower = actualTorque.*radSpeed;   % W
motorInputPower = mecPower+copperLoss+eddyCurrentLoss+windingLoss; % W
efficiencyMotor = mecPower./ motorInputPower; % Percent

%% Modèle de l'onduleur Tritium WaveSculptor22
Vbus = 150; % V ********************** TO DO : Remplacer par le modèle de la batterie *******************************

alpha = 3.3450E-3; % linear component of the switching loss (per unit of bus voltage)
beta = 1.8153E-2; % constant component of the switching loss (per unit of bus voltage)
Cfeq = 1.5625E-4; % (F) equivalent capacitance*frequency product of the entire controller
Req = 1.0800E-2; % (ohm) equivalent resistance of the entire controller

driveLoss = Req*phCurrentRMS.^2+(alpha.*phCurrentRMS+beta).*Vbus+Cfeq.*Vbus.^2; % W
driveInputPower = motorInputPower+driveLoss;
efficiencyDrive = motorInputPower/driveInputPower;


