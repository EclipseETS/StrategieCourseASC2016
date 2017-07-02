
figure
grid on, title('Graphique des prévisions solaire')

for k = 1:length(meteo.global_horizontal_irradiance)
    plot(meteo.global_horizontal_irradiance , 'r');
%     plot(meteo.direct_irrandiance , 'b');
end



xlabel('Heure')
ylabel('Puissance du soleil (W/m^2)')
legend('GHI');
% legend('DNI');