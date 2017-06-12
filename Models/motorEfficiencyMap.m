%% Éclipse 9
%  motorEfficiencyMap.m
%  Permet de calculer les pertes dans les moteurs CSIRO du véhicule solaire Éclipse 9
%  
%  Les paramètres proviennent du document Application Notes pour un moteur
%  Marand (CSiro)
%
%  Auteur : Julien Longchamp
%  Date de création : 07-06-2017
%  Dernière modification :
%%

clc, close all, clear all

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

nbPts = 100;
rangeTorque = linspace(0.1,2*16,nbPts);
rangeRadSpeed = linspace(0.1, 2*111, nbPts);
tempAmbiant = 300; % K
tempWinding = tempAmbiant; % K
SoC = 1; % (%)
cellModel = load('../Data/ECLIPSE9_cells_discharge.mat'); % Octave

p = 1;
for k = 1 : nbPts
    for m = 1 : nbPts
        actualTorque = rangeTorque(k);
        radSpeed = rangeRadSpeed(m);
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
        
        totalMotorsInputPower(k,m) = mecPowerDeuxMoteurs+2*(copperLoss+eddyCurrentLoss+windingLoss); % W
        efficiencyMotors(k,m) = mecPowerDeuxMoteurs./ totalMotorsInputPower(k,m); % Percent
        motorsLosses(k,m) = 2*(copperLoss+eddyCurrentLoss+windingLoss);
    end
end

[X, Y] = meshgrid(rangeRadSpeed, rangeTorque);

figure, title('Motor Efficiency Map')
surf(rangeRadSpeed, rangeTorque, efficiencyMotors);
axis([min(rangeRadSpeed) max(rangeRadSpeed) min(rangeTorque) max(rangeTorque) 0.8 1]);

% mecPowerDeuxMoteurs = actualTorque.*radSpeed;   % W
% torqueUnmoteur = actualTorque/2;    % Nm
% tempMagnet = 0.5*(tempAmbiant + tempWinding); % K
% magnetB = 1.32-(1.2e-3)*(tempMagnet-293);  % T
% phCurrentRMS = 0.561.*magnetB.*torqueUnmoteur; % Arms
% windingRes = 0.0575*(1+0.0039*(tempWinding-293)); % ohm
% copperLoss = 3*phCurrentRMS.^2*windingRes; % W
% eddyCurrentLoss = ((9.602e-6).*(magnetB.*radSpeed).^2)./windingRes; % W
% windingLoss = (170.4e-6).*radSpeed.^2; % W
% outTempWinding = 0.455*(windingLoss + eddyCurrentLoss) + tempAmbiant; % K
% 
% totalMotorsInputPower = mecPowerDeuxMoteurs+2*(copperLoss+eddyCurrentLoss+windingLoss); % W
% efficiencyMotors = mecPowerDeuxMoteurs./ totalMotorsInputPower; % Percent
% motorsLosses = 2*(copperLoss+eddyCurrentLoss+windingLoss);