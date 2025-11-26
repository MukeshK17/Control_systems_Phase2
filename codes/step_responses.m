clc; clear; close all;


Ts = 0.02;                    
nx = 3;                       
folderPath = 'D:\control systems\1\';

filenames = fullfile(folderPath, {
    'data1.txt','data2.txt','data3.txt',...
    'data4.txt','data5.txt','data6.txt'});

N = length(filenames);
datasets = cell(N,1);


for i = 1:N
    T = readtable(filenames{i});
    u = T.servo_deg;
    y = T.dist_cm;
    datasets{i} = iddata(y, u, Ts);
end


sys_all = cell(N,1);

for k = 1:N
    z = datasets{k};
    sysd = n4sid(z, nx);        % discrete model
    sys  = d2c(sysd, 'zoh');    % continuous open-loop model
    sys_all{k} = sys;
end


figure;
tiledlayout(3,2);

for k = 1:N
    nexttile;

    [y_step, t_step] = step(sys_all{k});

    plot(t_step, y_step, 'LineWidth', 1.5);
    grid on;
    title(['Open-Loop Step Response - Data ', num2str(k)]);
    xlabel('Time (s)');
    ylabel('Output');
end


figure; hold on; grid on;
colors = lines(N);

for k = 1:N
    [y,t] = step(sys_all{k});
    plot(t, y, 'LineWidth', 1.5, 'Color', colors(k,:));
end

legend('Data 1','Data 2','Data 3','Data 4','Data 5','Data 6', ...
       'Location','best');
title('Open-Loop Step Response Comparison (All Datasets)');
xlabel('Time (s)');
ylabel('Output');
