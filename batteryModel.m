%% �clipse 9
%  Mod�le du batterie pack
%  
%  Les param�tres proviennent de la datasheet suivante :
%   https://www.akkuteile.de/tpl/download/NCR-18650BF.pdf
%
%  Auteur : Julien Longchamp
%  Date de cr�ation : 26-02-2016
%  Derni�re modification :
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
Ibatt_max = Crate_max*Ccell*nb_cell_para;

Battery_capacity = Ccell*nb_cell_total;

% Points provenant de la courbe de d�charge caract�ristique
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
continous_discharge_0p2C = polyval(p1, continous_capacity);
continous_discharge_1C = polyval(p2, continous_capacity);
continous_discharge_2C = polyval(p3, continous_capacity);

figure, hold on
plot(discharge_0p2C(:,1), discharge_0p2C(:,2), 'sr')
plot(continous_capacity,continous_discharge_0p2C, 'r')
plot(discharge_1C(:,1), discharge_1C(:,2), 'sb')
plot(continous_capacity,continous_discharge_1C, 'b')
plot(discharge_2C(:,1), discharge_2C(:,2), 'sg')
plot(continous_capacity,continous_discharge_2C, 'g')

