% =====================================================================
%  State-Space Estimation + Averaging using n4sid
%  CSV format per file: [time(s), servo_angle(deg), distance(cm)]
%
%  User enters a vector of run numbers
%  Example input: [2 3 6]
%  → Files loaded: '2_up.csv', '3_up.csv', '6_up.csv'
% =====================================================================

clear; clc; close all;
fprintf("\n--- State Space Identification from Selected CSV Runs ---\n");

% ===================== USER INPUT ===============================
runs = input("Enter run numbers (e.g. [2 3 6]): ");

if ~isnumeric(runs)
    error("Input must be a numeric vector, e.g. [2 5 7]");
end

nFiles = numel(runs);

fileNames = cell(1, nFiles);
for i = 1:nFiles
    fileNames{i} = sprintf("%d_up.csv", runs(i));
end

fprintf("\nFiles to process:\n");
disp(fileNames');

% Model order
order = input("Enter model order for n4sid (e.g. 2, 3, 4): ");

% ===================== STORAGE ===============================
Acell = cell(nFiles,1);
Bcell = cell(nFiles,1);
Ccell = cell(nFiles,1);
Dcell = cell(nFiles,1);
TsList = zeros(nFiles,1);

% ===================== MAIN LOOP ===============================
for k = 1:nFiles
    fname = fileNames{k};
    fprintf("\nProcessing file %d/%d : %s\n", k, nFiles, fname);

    if ~isfile(fname)
        error("File not found: %s", fname);
    end

    T = readmatrix(fname);

    t = T(:,1);
    u = T(:,2);
    y = T(:,3);

    % Remove NaNs
    ok = ~isnan(t) & ~isnan(u) & ~isnan(y);
    t = t(ok); u = u(ok); y = y(ok);

    % Sampling time
    dt = diff(t);
    Ts = median(dt);
    TsList(k) = Ts;

    % iddata object
    data = iddata(y, u, Ts);

    % n4sid model identification
    sys_id = n4sid(data, order, 'Display','off');

    % Store matrices
    Acell{k} = sys_id.A;
    Bcell{k} = sys_id.B;
    Ccell{k} = sys_id.C;
    Dcell{k} = sys_id.D;
end

% ===================== AVERAGING ===============================
Aavg = mean(cat(3, Acell{:}), 3);
Bavg = mean(cat(3, Bcell{:}), 3);
Cavg = mean(cat(3, Ccell{:}), 3);
Davg = mean(cat(3, Dcell{:}), 3);

Ts_final = median(TsList);

fprintf("\nFinal averaged sampling time Ts = %.6f seconds\n", Ts_final);

% ===================== BUILD MODELS ===============================
sysd = ss(Aavg, Bavg, Cavg, Davg, Ts_final);       % discrete SS model

tf_d = tf(sysd);    % discrete TF
tf_d = tf_d(1,1);   % ensure SISO

sysc = d2c(sysd, 'zoh');   % convert to continuous (ZOH)
tf_c = tf(sysc);

% ===================== DISPLAY RESULTS ===============================

fprintf("\n---- Averaged State Space Matrices (Discrete) ----\n");
Aavg
Bavg
Cavg
Davg

fprintf("\n---- Discrete Transfer Function (distance/servo angle) ----\n");
tf_d

fprintf("\n---- Continuous-Time Transfer Function (ZOH) ----\n");
tf_c

fprintf("\nDone.\n");


% Plots

% Root Locus (Plant TF Only)
figure;
rlocus(tf_c);
grid On;

% Bode Plot (Plant TF Only)
figure;
bode(tf_c);
grid On;

% Step Response (Plant TF Only)
figure;
t = 0:Ts:50;
step(tf_c, t)
grid on;
