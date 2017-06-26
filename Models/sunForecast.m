%% Éclipse 9
%  Update les donnees des previsions solaires pour la FSGP 2017.
%  Sauvegarde le résultat dans le fichier 'Data/SunForecastFSGP2017.mat'
%
%  Inputs :
%    latitude : Coordonnée GPS décimale
%    longitude : Coordonnée GPS décimale
%    
% Structure de l'API
% Property	Description
% ghi	Global Horizontal Irradiance (W/m2) – centre value (mean).
% ghi10	Global Horizontal Irradiance (W/m2) – 10th percentile value (low scenario)
% ghi90	Global Horizontal Irradiance (W/m2) – 90th percentile value (high scenario)
% dni	Direct Normal Irradiance (W/m2) – centre value (mean)
% dni10	Direct Normal Irradiance (W/m2) – 10th percentile value (low scenario)
% dni90	Direct Normal Irradiance (W/m2) – 90th percentile value (high scenario)
% dhi	Diffuse Horizontal Irradiance
% air_temp	Air temperature (degrees Celsius)
% zenith	Solar zenith angle (degrees). Zero means directly upwards/overhead). Varies from 0 to 180. A value of 90 means the sun is at the horizon.
% azimuth	Solar azimuth angle (degrees). Zero means true north. Varies from -180 to 180. Positive is anticlockwise (west). A value of -90 means the sun is in the east.
% cloud_opacity	The attenuation of incoming light due to cloud. Varies from 0 (no cloud) to 100 (full attenuation of incoming light).
%
%  Auteur : Megane Lavallee
%  Date de création : 25-06-2017
%  Dernière modification :
%%

Latitude = '30.134';
Longitude = '-97.635';
url = ['https://api.solcast.com.au/radiation/forecasts?longitude=' Longitude '&latitude=' Latitude '&format=json&api_key=DowFFmYJnUK_IEhY6Az6nkcer_os0HR2'];
try  
%     api = 'https://api.solcast.com.au/radiation/forecasts?longitude=-97.635&latitude=30.134&format=json&api_key=DowFFmYJnUK_IEhY6Az6nkcer_os0HR2';
    donnees_solaire = webread (url);
catch e
    disp(e)
    disp('ALERTE : Les prévisions solaires n''ont pas été mises à jour')
end

    forecasts = struct2cell(donnees_solaire.forecasts);
    global_horizontal_irradiance = cell2mat(forecasts(1,:));
    direct_normal_irradiance = cell2mat(forecasts(4,:));
    diffuse_horizontal_irradiance = cell2mat(forecasts(7,:));
    
    date = zeros(length(forecasts), 6);
    for k = 1:length(forecasts)
        startingTime = strsplit(strjoin(forecasts(13,k)), 'T');
        startingHour = char(startingTime(end));
        startingHour = startingHour(1:end-1);
        startingTime = strjoin([startingTime(1) ' ' startingHour]);
        startingTime = datestr(datenum(startingTime)-5/24, 'yyyy-mm-dd HH:MM:SS'); % Correction du décalage entre UTC et CDT (Austin, Texas UTC-5)
        date(k,:) = datevec(startingTime, 'yyyy-mm-dd HH:MM:SS');
    end
    
    
%     date(:,4) = date(:,4) - 5;
    
    solarForecast.global_horizontal_irradiance = global_horizontal_irradiance;
    solarForecast.direct_normal_irradiance = direct_normal_irradiance;
    solarForecast.diffuse_horizontal_irradiance = diffuse_horizontal_irradiance;
    solarForecast.global_direct_irradiance = direct_normal_irradiance+diffuse_horizontal_irradiance;
    solarForecast.date = date;
    
    filename = ['../Data/SunForecastFSGP2017' datestr(now, '-mmm-dd') '.mat'];  
    save(filename, 'solarForecast');
    disp('Les prévisions solaires ont été mises à jour')

