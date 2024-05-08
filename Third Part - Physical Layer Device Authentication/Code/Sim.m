n_round = 50; % Number of simulation rounds
% Over class of Bluetooth, we have the following:
% Class 1 = 20 dB in power and expected distance of 100 m.
% Here, we establish an avg range in which to send 10 dB of 50 m.,
% according to Bluetooth class 1

% Definition of SNR
SNR_min = 10; % Minimum SNR in dB
SNR_max = 30; % Maximum SNR in dB
SNR_step = 1; % SNR step size
SNR = SNR_min:SNR_step:SNR_max;
power = 10.^(SNR/10);

% Define signal parameters
signal_length = 100; % Length of the signals
% Determine min and max power (over range of Bluetooth and its bounds)
% Ideally, between avg value (-20; 20) is for all Bluetooth
power_X = -10; % Power for bit 0
power_Y = 10; % Power for bit 1

% Initialize signals
data_signal = zeros(1, signal_length);
authentication_signal = zeros(1, signal_length);

% Generate data signal
bit_sequence = randi([0, 1], 1, signal_length); % Generate random bit sequence
for i = 1:signal_length
    if bit_sequence(i) == 1
        data_signal(i) = power_Y;
    else
        data_signal(i) = power_X;
    end
end

% Generate authentication signal
bit_sequence = randi([0, 1], 1, signal_length); % Generate random bit sequence
for i = 1:signal_length
    if bit_sequence(i) == 1
        authentication_signal(i) = power_Y;
    else
        authentication_signal(i) = power_X;
    end
end

% Plot signals
figure;
subplot(2, 1, 1);
plot(data_signal);
title('Data Signal');
xlabel('Time'); % assuming we send a bit each second
ylabel('Power');

subplot(2, 1, 2);
plot(authentication_signal);
title('Authentication Signal');
xlabel('Time');
ylabel('Power');

% Definition of simulation parameters
% Distance = max. 50 m. with step 1 (from 1 to 50)
% FA rate = increasing rate
% MD rate = increasing rate

% When FA increases, MD decreases
% Conversely, when FA decreases, MD increases
% FA is important but slightly less than MD
% The second one allows to find how many errors we do
% because false positives are slightly different problems

% Conventionally and looking at other sims, we find value to
% be beneath the decimal threshold

% Define simulation parameters
max_distance = 50; % Maximum distance in meters

% Initialize arrays to store target FA and MD rates
target_FA_rates = zeros(1, max_distance);
target_MD_rates = zeros(1, max_distance);

% Generate target FA and MD rates for each distance
for distance = 1:max_distance
    % Define ranges for FA rates
    min_FA_rate = 0.01; % Minimum FA rate
    max_FA_rate = 0.3; % Maximum FA rate
    
    % Define ranges for MD rates
    min_MD_rate = 0.1; % Minimum MD rate
    max_MD_rate = 0.5; % Maximum MD rate
    
    % Generate target MD and FA rates with increasing rate for each distance
    distance_increment = (max_MD_rate - min_MD_rate) / 50;
    target_MD_rates(distance) = min_MD_rate + (distance - 1) * distance_increment;
    target_FA_rates(distance) = min_FA_rate + (distance - 1) * distance_increment;
end

% Display the generated target FA and MD rates for the first distance
fprintf('Generated Target FA Rates for Distance:\n');
disp(target_FA_rates);

fprintf('Generated Target MD Rates for Distance:\n');
disp(target_MD_rates);

%% TODO - Trovare i relativi epsilon (punto medio FA)?

% Initialize signal S
S = zeros(1, signal_length);

% Combine signals bit by bit
for i = 1:signal_length
    % Combine bits from data_signal and authentication_signal
    S(i) = data_signal(i) + authentication_signal(i);
end

% Plot the combined signal (this is the sent signal)
figure;
plot(S);
title('Combined Signal (S)');
xlabel('Time');
ylabel('Power');

% Transformation of signal into real values

% % Convert combined signal S to real values
% S_real = 10.^(S/10);
% 
% % Interpolate the signal to generate a smoother curve
% t = 1:signal_length;
% t_interp = linspace(1, signal_length, 10*signal_length); % Increase resolution for interpolation
% S_interp = interp1(t, S, t_interp, 'spline');
% 
% % Plot the interpolated signal
% figure;
% plot(t_interp, S_interp);
% title('Sinusoidal Signal (Interpolated)');
% xlabel('Time');
% ylabel('Power');

% % Assuming center is 0 (given the signal is -10 and 10)
% center = 0;
% 
% % Initialize arrays to store BER values
% BER_data = zeros(max_distance, length(SNR));
% BER_auth = zeros(max_distance, length(SNR));
% 
% % Loop through each distance
% for j = 1:max_distance
%     % Loop through each SNR level
%     for k = 1:length(SNR)
% 
%         % Generate the transmitted signal
%         transmitted_signal = S;
%         % Generate the received signal by adding AWGN
%         received_signal = awgn(transmitted_signal, SNR(k));
%         
%         % Loop through each bit in the received signal
%         for i = 1:signal_length
%             % Decode the received signal
%             % Here, you would implement your decoding algorithm
%             
%         end
%     end
% end
% 
% % Calculate average BER values
% BER_data_avg = BER_data / N;
% BER_auth_avg = BER_auth / N;
% 
% % Plot BER values
% figure;
% subplot(2, 1, 1);
% surf(SNR, 1:max_distance, BER_data_avg');
% title('BER Data Signal');
% xlabel('SNR (dB)');
% ylabel('Distance');
% zlabel('BER');
% colorbar;
% 
% subplot(2, 1, 2);
% surf(SNR, 1:max_distance, BER_auth_avg');
% title('BER Authentication Signal');
% xlabel('SNR (dB)');
% ylabel('Distance');
% zlabel('BER');
% colorbar;


