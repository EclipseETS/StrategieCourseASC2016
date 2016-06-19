%% �clipse 9
%  PMG_caracterisation.m
%  Permet de caract�riser la voiture solaire �clipse 9 � partir des
%  fichiers de log des essais r�alis�s chez PMG
%  
%
%  Auteur : Julien Longchamp
%  Date de cr�ation : 18-06-2016
%  Derni�re modification :
%%
clc, clear all, close all
addpath('C:\Users\club\Git\log-PMG\log-PMG\log 2016-06-18\DonneesMatlabTraitees')

%filename = 'MathLab_2016_06_18_01_10_24 premiers tours-julien B.xlsx';
%filename = 'MathLab_2016_06_18_01_38_14 lap 50 kmh - julien B.xlsx';
%filename = 'MathLab_2016_06_18_02_52_04 premier tour max power-Remi.xlsx';
%filename = ['MathLab_2016_06_18_12_41_22 tour - JF' '.xlsx'];

data = xlsread(filename);
heure = data(:,1);
vitesse = data(:,2);
rpm = data(:,3);
VbusDC = data(:,4);
IbusDC = data(:,5);
Odometre = data(:,6);
Ah = data(:,7);

dt = diff(heure)./min(diff(heure));
t = [0; cumsum(dt)]; % En secondes

figure, hold on, title('Aper�u de l''essai')
plot(t,VbusDC)
plot(t, IbusDC, 'r')
plot(t, vitesse, 'g-')
legend('VbusDC', 'IbusDC', 'Vitesse (km/h)')
