%% No compensator/PID
clc, clearvars, close all;

% Open Loop TF (~ Plant TF)
num = [0.05759 -11.51 -175.9];
den = [1 166.1 6798 -267.6];
G = tf(num,den);


% Open Loop Poles and Nyquist plot

p = pole(G)    % or roots(den)
figure; nyquist(G); grid on;
% Didn't encircle, N = 0, hence 1 CL Pole in RHP (Unstable)


% Close Loop Poles and Root Locus

Gcl = feedback(G, 1);
p_cl = pole(Gcl)
figure; rlocus(G); grid on;
% One CL Pole on RHP, unstable

% Bode Plot and Margins
figure; margin(G);
% Infinite Phase and Gain Margins!!

%% With Compensator/PID
clc, clearvars, close all;

% PID-derived compensator
C_num = [-112.38637259776269, -1040.1973001575782, -300.6016119269314];
C_den = [1.0, 8.47784343675806, 0.0];

% Plant G(s)
G_num = [0.05759, -11.51, -175.9];
G_den = [1.0, 166.1, 6798.0, -267.6];

% Create transfer functions
C = tf(C_num, C_den);   % compensator
G = tf(G_num, G_den);   % plant

% Series (open-loop) L(s) = C(s)*G(s)
L = series(C, G);       % or L = C*G;


% Open Loop Poles and Nyquist plot

p = pole(L)    % or roots(den)
figure; nyquist(L); grid on;



% Close Loop Poles and Root Locus

Lcl = feedback(L, 1);
l_p_cl = pole(Lcl)
figure; rlocus(L); grid on;


% Bode Plot and Margins
figure; margin(L);


