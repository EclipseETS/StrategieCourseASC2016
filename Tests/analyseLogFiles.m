% analyseLogFiles.m

clc, clear all, close all

path = 'C:\Git\Log_Telemetry\PMG 10 juin 2017\*\*\'
%path = '*\';
list = dir([path '*.mat']);

mass = 300; % kg (Masse totale avec pilote)

for k = 1:numel(list)
    fullpath = [list(k).folder '\' list(k).name];
    load(fullpath);
    
    folders=regexp(fullpath,'\','split');
    
    if numel(data.time) == numel(data.DRIVE_L_VEHICLE_VELOCITY_ID)    
    nameFig = [folders(end-2) ; ' : Speed'];    
    figure('Name', char(nameFig)), hold on, title(nameFig)
    plot(data.time, data.DRIVE_L_VEHICLE_VELOCITY_ID)
    plot(data.time, data.DRIVE_R_VEHICLE_VELOCITY_ID, 'r')
    legend('Drive LEFT', 'Drive RIGTH')
    xlabel('Time')
    ylabel('Speed')    
    
%     nameFig = [folders(end-2) ; ' : Batterie'];     
%     figure('Name', char(nameFig)), hold on, title(nameFig)
%     plotyy(data.time, data.BMS_PACK_CURRENT_ID,data.time, data.BMS_PACK_VOLTAGE_ID)
%     %plot(data.time, data.BMS_PACK_VOLTAGE_ID, 'r')
%     legend('Batterie courant', 'Batterie voltage')
%     xlabel('Time')
%    ylabel('Courant', 'Tension')    
%    mecPower = data.DRIVE_L_VEHICLE_VELOCITY_ID .* 
        
    
    end
    
end