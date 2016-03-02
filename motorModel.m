%% Éclipse 9
%  Modèle du moteur 
%  
%  Les paramètres proviennent du document Application Notes pour un moteur
%  Marand (CSiro)
%
%  Auteur : Julien Longchamp
%  Date de création : 03-03-2016
%  Dernière modification :
%%

% Paramètres du moteur Marand (CSiro)
numPoles = 40;
numPolesPairs = numPoles/2;
numPhases = 3;
motorWheelMass = 13; % kg (Include the whole wheel assembly) TO BE VERIFIED
nomSpeed = 111;     % rad/s
nomTorque = 16.2;   % Nm
airGap = 0.00175;   % m
phasesRes = 0.0575; % ohm
kV = 0.45;          % Vs/rad  EMF constant
kA = 0.44;          % Nm/A    Torque constant per phase
inductorMass = 1.11; % kg
inductorRes = 0.00627; % ohm
inductorVal = 95e-6; % H

% Modèle Steady-State
tempAmbiant = 300; % K initial value (27°C)
tempWinding = 300; % K initial value (27°C)
tempMagnet = 0.5*(tempAmbiant + tempWinding); % K
magnetB = 1.32-(1.2e-3)*(tempMagnet-293);  % T
phCurrentRMS = 0.561*magnetB*actualTorque; % Arms
windingRes = 0.0575*(1+0.0039*(tempWinding-293)); % ohm
copperLoss = 3*phCurrentRMS.^2*windingRes; % W
eddyCurrentLoss = ((9.602e-6)*(magnetB*radSpeed).^2)/windingRes; % W
tempWinding = 0.455*(windingLoss + eddyCurrentLoss) + tempAmbiant; % K
windingLoss = (170.4e-6)*radSpeed^2; % W
mecPower = actualTorque*radSpeed;   % W
efficiency = mecPower/(mecPower+copperLoss+eddyCurrentLoss+windingLoss); % Percent


