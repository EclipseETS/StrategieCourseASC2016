function Vbatt = batteryModel(SoC, Ibatt)

if nargin == 0
Ibatt = 0;
SoC = 0.95;
end

%% Éclipse 9
%  Modèle du batterie pack
%  
%  Les paramètres proviennent de la datasheet suivante :
%   https://www.akkuteile.de/tpl/download/NCR-18650BF.pdf
%
%  Auteur : Julien Longchamp
%  Date de création : 26-02-2016
%  Dernière modification :
%%

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


Rint = nb_cell_serie/nb_cell_para*Rcell;    % ohm


% Points provenant de la courbe de décharge caractéristique
discharge_0p2C = [0 4.2;
                .10 4.1;
                .50 4.0;
               1.00 3.85;
               1.50 3.7;
               2.00 3.6;
               2.50 3.45;
               3.00 3.3;
               3.35 2.5;];
           
discharge_1C =   [0 4.0;
                .10 3.9;
                .50 3.8;
               1.00 3.7;
               1.50 3.5;
               2.00 3.4;
               2.50 3.3;
               3.00 3.1;
               3.35 2.5;];
           
discharge_2C =   [0 3.75;
                .10 3.7;
                .50 3.6;
               1.00 3.5;
               1.50 3.35;
               2.00 3.25;
               2.50 3.1;
               3.00 2.8;
               3.35 2.5;];
           
continous_capacity = linspace(0,3.35,1000);
p1 = polyfit(discharge_0p2C(:,1), discharge_0p2C(:,2), 7);
p2 = polyfit(discharge_1C(:,1), discharge_1C(:,2), 7);
p3 = polyfit(discharge_2C(:,1), discharge_2C(:,2), 7);

capacite_restante = Ccell * (1-SoC);

% Si la fonction est appelée pour un point précis
if length(SoC) == 1 
    if (Ibatt <= 0.4*Ibatt_nom) % Choisir la courbe 0,2C si Ibatt <= 0,4C
        Ecell_inst = polyval(p1, capacite_restante);
        Ebatt = Ecell_inst * nb_cell_serie;
    elseif (Ibatt > 0.4*Ibatt_nom && Ibatt <= 1.5*Ibatt_nom) % Choisir la courbe 1C si 0,4 < Ibatt <= 1,5
        Ecell_inst = polyval(p2, capacite_restante);
        Ebatt = Ecell_inst * nb_cell_serie;
    elseif (Ibatt > 1.5*Ibatt_nom) % Choisir la courbe 2C si Ibatt < 1,5
        Ecell_inst = polyval(p3, capacite_restante);
        Ebatt = Ecell_inst * nb_cell_serie;
    end
elseif size(SoC) == size(Ibatt) % Si la fonction est appelée avec des vecteurs en arguments
    Ebatt = zeros(size(SoC));
    for k=1:length(SoC)
        if (Ibatt(k) <= 0.4*Ibatt_nom) % Choisir la courbe 0,2C si Ibatt <= 0,4C
            Ecell_inst = polyval(p1, capacite_restante(k));
            Ebatt(k) = Ecell_inst * nb_cell_serie;
        elseif (Ibatt(k) > 0.4*Ibatt_nom && Ibatt(k) <= 1.5*Ibatt_nom) % Choisir la courbe 1C si 0,4 < Ibatt <= 1,5
            Ecell_inst = polyval(p2, capacite_restante(k));
            Ebatt(k) = Ecell_inst * nb_cell_serie;
        elseif (Ibatt(k) > 1.5*Ibatt_nom) % Choisir la courbe 2C si Ibatt < 1,5
            Ecell_inst = polyval(p3, capacite_restante(k));
            Ebatt(k) = Ecell_inst * nb_cell_serie;
        end
    end
end
    
Vbatt = Ebatt-Rint*Ibatt;

% Cell_full_capacity = sum(continous_discharge_1C).* mean(diff(continous_capacity));   % Capacité de la batterie à 1C
% Battery_full_capacity = nb_cell_total * Cell_full_capacity;

continous_discharge_0p2C = polyval(p1, continous_capacity);
continous_discharge_1C = polyval(p2, continous_capacity);
continous_discharge_2C = polyval(p3, continous_capacity);

if nargin == 0
figure, hold on
plot(discharge_0p2C(:,1), discharge_0p2C(:,2), 'sr')
plot(continous_capacity,continous_discharge_0p2C, 'r')
plot(discharge_1C(:,1), discharge_1C(:,2), 'sb')
plot(continous_capacity,continous_discharge_1C, 'b')
plot(discharge_2C(:,1), discharge_2C(:,2), 'sg')
plot(continous_capacity,continous_discharge_2C, 'g')
xlabel('Capacité (AH)')
ylabel('Tension (V)')
end

decharge0C2 = p1;
decharge1C = p2;
decharge2C = p3;
%save('Eclipse9_cells_discharge.mat', 'decharge0C2', 'decharge1C', 'decharge2C');

%% Section spéciale pour le calcul de l'élévation de la température dans le battery pack d'Éclipse 9

% Configuration du battery pack
chaleur_massique = 830; % J/(kg*°C) tiré de http://www.inforlab-chimie.fr/doc/document_fichier_279.pdf
nb_cell_serie = 38;
nb_cell_para = 11;
nb_cell_total = nb_cell_serie*nb_cell_para;
Rcell = 0.125;      % ohm (NRC18560B from http://lygte-info.dk/review/batteries2012/Common18650Summary%20UK.html) 
Rint = nb_cell_serie/nb_cell_para*Rcell;    % ohm
masse_batt = 20; % kg

% Conditions d'opération
T_ambiant = 45; % Celsius
Tension_batt = 134; % V
Courant_batt = 50; % A

batteryLosses = Rint.*Courant_batt.^2;   % W
temps = 270;% s      Le tour de Rémi à 80km/h sur une piste de 6 km = 4.5 min


if nargin == 0
battetyTempRise = batteryLosses*temps/(masse_batt*chaleur_massique)
battetyFinalTemp = T_ambiant+battetyTempRise

figure, hold on, title('ÉCLIPSE IX : Battery pack discharge')
plot(discharge_0p2C(:,1), nb_cell_serie*discharge_0p2C(:,2), '*r')
plot(continous_capacity,nb_cell_serie*continous_discharge_0p2C, 'r')
plot(discharge_1C(:,1), nb_cell_serie*discharge_1C(:,2), 'sb')
plot(continous_capacity,nb_cell_serie*continous_discharge_1C, 'b')
plot(discharge_2C(:,1), nb_cell_serie*discharge_2C(:,2), '+g')
plot(continous_capacity,nb_cell_serie*continous_discharge_2C, 'g')
xlabel('Capacity (AH)')
ylabel('Voltage (V)')
legend('7.37 A (0.2C)', '36.85 A (1C)', '73.70 A (2C)')
end

