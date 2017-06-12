%% readLogFile.m

clc, clear all, close all

% Select the path to the log files
path = 'C:\Git\Log_Telemetry\PMG 10 juin 2017\';
list = dir([path '*\*.dat']);


% for k = 1:numel(list)
%     fullpath = [list(k).folder '\' list(k).name];
%     raw_data = csvread(fullpath, 0, 1);
%     data.time = 0:length(data); % s
%     data.DRIVE_L_BUS_VOLTAGE_ID = data(:,1);
%     data.DRIVE_L_BUS_CURRENT_ID = data(:,2);
%     data.DRIVE_L_MOTOR_VELOCITY_ID = data(:,3);
%     data.DRIVE_L_VEHICLE_VELOCITY_ID = data(:,4);
%     data.DRIVE_L_ODOMETER_ID = data(:,5);
%     data.DRIVE_L_DCBUS_AMPHOUR_ID = data(:,6);
%     data.DRIVE_R_BUS_VOLTAGE_ID = data(:,7);
%     data.DRIVE_R_BUS_CURRENT_ID = data(:,8);
%     data.DRIVE_R_MOTOR_VELOCITY_ID = data(:,9);
%     data.DRIVE_R_VEHICLE_VELOCITY_ID = data(:,10);
%     data.DRIVE_L_ODOMETER_ID = data(:,11);
%     data.DRIVE_R_DCBUS_AMPHOUR_ID = data(:,12);
%     data.BMS_PACK_CURRENT_ID = data(:,13);
%     data.BMS_PACK_VOLTAGE_ID = data(:,14);
%     data.BMS_PACK_TEMP_HIGH_ID = data(:,15);
%     data.BMS_PACK_TEMP_LOW_ID = data(:,16);
%     data.BMS_REMAINING_ENERGY_ID = data(:,17);
%     data.VOLANT_VEHICLE_VELOCITY_ID = data(:,18);
%     data.MUPPET_UIN_MPPT1_ID = data(:,19);
%     data.MUPPET_IIN_MPPT1_ID = data(:,20);
%     data.MUPPET_UIN_MPPT2_ID = data(:,21);
%     data.MUPPET_IIN_MPPT2_ID = data(:,22);
%     data.MUPPET_UIN_MPPT3_ID = data(:,23);
%     data.MUPPET_IIN_MPPT3_ID = data(:,24);
%     save([fullpath '.mat'], 'data')
% end

%% Format des données brutes
% date.toString()+sep+//HEURE
% dd.getRawValue(DRIVE_L_ID, DRIVE_L_BUS_VOLTAGE_ID)+sep+
% dd.getRawValue(DRIVE_L_ID, DRIVE_L_BUS_CURRENT_ID)+sep+
% dd.getRawValue(DRIVE_L_ID, DRIVE_L_MOTOR_VELOCITY_ID)+sep+
% dd.getRawValue(DRIVE_L_ID, DRIVE_L_VEHICLE_VELOCITY_ID)+sep+
% dd.getRawValue(DRIVE_L_ID, DRIVE_L_ODOMETER_ID)+sep+
% dd.getRawValue(DRIVE_L_ID, DRIVE_L_DCBUS_AMPHOUR_ID)+sep+
% dd.getRawValue(DRIVE_R_ID, DRIVE_R_BUS_VOLTAGE_ID)+sep+
% dd.getRawValue(DRIVE_R_ID, DRIVE_R_BUS_CURRENT_ID)+sep+
% dd.getRawValue(DRIVE_R_ID, DRIVE_R_MOTOR_VELOCITY_ID)+sep+
% dd.getRawValue(DRIVE_R_ID, DRIVE_R_VEHICLE_VELOCITY_ID)+sep+
% dd.getRawValue(DRIVE_R_ID, DRIVE_R_ODOMETER_ID)+sep+
% dd.getRawValue(DRIVE_R_ID, DRIVE_R_DCBUS_AMPHOUR_ID)+sep+
% dd.getRawValue(BMS_ID, BMS_PACK_CURRENT_ID)+sep+
% dd.getRawValue(BMS_ID, BMS_PACK_VOLTAGE_ID)+sep+
% dd.getRawValue(BMS_ID, BMS_PACK_TEMP_HIGH_ID)+sep+
% dd.getRawValue(BMS_ID, BMS_PACK_TEMP_LOW_ID)+sep+
% dd.getRawValue(BMS_ID, BMS_REMAINING_ENERGY_ID)+sep+
% dd.getRawValue(VOLANT_ID, VOLANT_VEHICLE_VELOCITY_ID)+sep+
% dd.getRawValue(MUPPET_ID, MUPPET_UIN_MPPT1_ID)+sep+
% dd.getRawValue(MUPPET_ID, MUPPET_IIN_MPPT1_ID)+sep+
% dd.getRawValue(MUPPET_ID, MUPPET_UIN_MPPT2_ID)+sep+
% dd.getRawValue(MUPPET_ID, MUPPET_IIN_MPPT2_ID)+sep+
% dd.getRawValue(MUPPET_ID, MUPPET_UIN_MPPT3_ID)+sep+
% dd.getRawValue(MUPPET_ID, MUPPET_IIN_MPPT3_ID)+
% "\r\n"