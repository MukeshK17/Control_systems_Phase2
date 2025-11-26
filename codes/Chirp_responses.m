clc; clear; close all;
% CHIRP SIGNAL RESPONSE
dataFolder = 'D:\control systems\1\';

files = {'data1.txt','data2.txt','data3.txt','data4.txt','data5.txt','data6.txt'};

figure;
tiledlayout(3,2);  

for i = 1:length(files)

    fname = fullfile(dataFolder, files{i});
    T = readtable(fname);

    time = T.time_ms/1000;  
    servo = T.servo_deg;
    dist  = T.dist_cm;

    nexttile;
    yyaxis left
    plot(time, servo, 'LineWidth', 1);
    ylabel('Servo (deg)')

    yyaxis right
    plot(time, dist, 'LineWidth', 1.5);
    ylabel('Distance (cm)')

    xlabel('Time (s)')
    title(['Response: ' files{i}])
    grid on
end
