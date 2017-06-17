%% readLogFile.m

clc, clear all, close all

% Select the path to the log files
%path = 'C:\Git\Log_Telemetry\PMG 10 juin 2017\Arret moteur\*\';
path = 'C:\Git\Log_Telemetry\PMG 10 juin 2017\*\*\'
%path = '*\';
list = dir([path '*.dat']);


for k = 1:numel(list)
    fullpath = [list(k).folder '\' list(k).name];
    raw_data = csvread(fullpath, 0, 1);
    data.time = (1:length(raw_data))'; % s
    data.DRIVE_L_BUS_VOLTAGE_ID = raw_data(:,1);
    data.DRIVE_L_BUS_CURRENT_ID = raw_data(:,2);
    data.DRIVE_L_MOTOR_VELOCITY_ID = raw_data(:,3);
    data.DRIVE_L_VEHICLE_VELOCITY_ID = raw_data(:,4);
    data.DRIVE_L_ODOMETER_ID = raw_data(:,5);
    data.DRIVE_L_DCBUS_AMPHOUR_ID = raw_data(:,6);
    data.DRIVE_R_BUS_VOLTAGE_ID = raw_data(:,7);
    data.DRIVE_R_BUS_CURRENT_ID = raw_data(:,8);
    data.DRIVE_R_MOTOR_VELOCITY_ID = raw_data(:,9);
    data.DRIVE_R_VEHICLE_VELOCITY_ID = raw_data(:,10);
    data.DRIVE_L_ODOMETER_ID = raw_data(:,11);
    data.DRIVE_R_DCBUS_AMPHOUR_ID = raw_data(:,12);
    data.BMS_PACK_CURRENT_ID = raw_data(:,13);
    data.BMS_PACK_VOLTAGE_ID = raw_data(:,14);
    data.BMS_PACK_TEMP_HIGH_ID = raw_data(:,15);
    data.BMS_PACK_TEMP_LOW_ID = raw_data(:,16);
    data.BMS_REMAINING_ENERGY_ID = raw_data(:,17);
    data.VOLANT_VEHICLE_VELOCITY_ID = raw_data(:,18);
    data.MUPPET_UIN_MPPT1_ID = raw_data(:,19);
    data.MUPPET_IIN_MPPT1_ID = raw_data(:,20);
    data.MUPPET_UIN_MPPT2_ID = raw_data(:,21);
    data.MUPPET_IIN_MPPT2_ID = raw_data(:,22);
    data.MUPPET_UIN_MPPT3_ID = raw_data(:,23);
    data.MUPPET_IIN_MPPT3_ID = raw_data(:,24);
    save([fullpath '.mat'], 'data')
end

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