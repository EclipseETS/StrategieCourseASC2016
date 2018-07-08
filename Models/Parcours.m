%% Parcours 2D et 3D du parcours
figure, hold on, title('Carte 2D du newParcours')
plot(newParcours.latitude, newParcours.longitude, '*')
plot(newParcours.latitude, newParcours.longitude, '.r')
legend('Donn�es brutes', 'Donn�es trait�es', 'location', 'southeast')
xlabel('Longitude')
ylabel('Latitude')

figure, hold on, title('Carte 3D du newParcours')
plot3(newParcours.latitude, newParcours.longitude, newParcours.altitude, '*')
plot3(newParcours.latitude, newParcours.longitude, newParcours.altitude, 'r.')
legend('Donn�es brutes', 'Donn�es trait�es', 'location', 'southeast')
xlabel('Longitude')
ylabel('Latitude')
zlabel('Altitude (m)')

figure, hold on, title('Altitude')
plot(newParcours.distance, newParcours.altitude, '.')
plot(newParcours.distance, newParcours.altitude, 'r.')
legend('Donn�es brutes', 'Donn�es trait�es')
xlabel('Distance (km')
ylabel('Altitude (m)')

figure, hold on, title('Pente filtr�e')
plot(newParcours.distance, newParcours.slope)
xlabel('Distance (km')
ylabel('Pente (%)')
