%% Éclipse 9
%  Optimisation d'une étape de l'ASC2016
%  
%  Permet de trouver un profil de vitesse optimal pour la voiture en
%  fonction d'un parcours prédéterminé.
%  
%  Auteur : Julien Longchamp
%  Date de création : 02-03-2016
%%

clc, clear all, close all

%% IMPORTATION DES DONNÉES EN FORMAT .MAT DE L'ASC2016
load('etapesASC2016.mat')

parcours = etape1;

distance_totale = parcours.distance(end);   % km
nbPoints = length(parcours.distance);       % nombre d'intervals pour la simulation

% Contraintes du parcours
vitesse_min = 60/3.6;   % m/s (60 km/h)
vitesse_max = 120/3.6;  % m/s (120 km/h)
vitesse_ini = 0;        % m/s
accel_max = 1.3;       % m/s^2

% Paramètres du véhicule Éclipse 9
masse_totale = 225;     % kg
aire_frontale = 1.14;   % m^2
coef_trainee = 0.135;   % coefficient de trainée aérodynamique
rayon_roue = 0.2575;    % m
surface_solaire = 6;    % m^2

% Constantes physiques
const_grav = 9.81;      % m/s^2
densite_air = 1.15;     % kg/m^3

% Paramètres des moteurs
nb_moteur = 2;
vitesse_nom = 111;  % rad/s
couple_nom = 16.2;  % Nm
Kv = 0.45;          % V/rad/s (Constante EMF)
Ka = 0.44;          % Nm/A (Constante de couple)
puissance_max = 1800; % W



% Initialisation des vecteurs pour la simulation
vitesse_cible = 70/3.6; % m/s
profil_vitesse = zeros(nbPoints,1);
temps_interval = zeros(nbPoints,1);
temps_cumulatif = zeros(nbPoints,1);
for k=2:nbPoints
    if(profil_vitesse(k-1) < vitesse_cible)
        temps_interval(k) = sqrt(2.*parcours.distance_interval(k-1)./accel_max);
        profil_vitesse(k) = profil_vitesse(k-1)+accel_max.*temps_interval(k);
    [profil_vitesse(k) k]
    else
        profil_vitesse(k) = profil_vitesse(k-1);
        temps_interval(k) = parcours.distance_interval(k)/profil_vitesse(k);
    end
    temps_cumulatif(k) = temps_cumulatif(k-1) + temps_interval(k);
end

figure, plot(profil_vitesse)
figure, plot(temps_cumulatif, profil_vitesse);


