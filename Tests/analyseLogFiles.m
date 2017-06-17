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
    figure, hold on, title([folders(end-2) ' : Speed'])
    plot(data.time, data.DRIVE_L_VEHICLE_VELOCITY_ID)
    plot(data.time, data.DRIVE_R_VEHICLE_VELOCITY_ID, 'r')
    legend('Drive LEFT', 'Drive RIGTH')
    xlabel('Time')
    ylabel('Speed')    
    
    mecPower = data.DRIVE_L_VEHICLE_VELOCITY_ID .* 
        
    
    end
    
end