clear all;
clc;

n_rounds = 50; % Number of simulation rounds
% Over class of Bluetooth, we have the following:
% Class 1 = 20 dB in power and expected distance of 100 m.
% Here, we establish an avg range in which to send 10 dB of 50 m.,
% according to Bluetooth class 1

% Definition of SNR
SNR_min = 10; % Minimum SNR in dB
SNR_max = 30; % Maximum SNR in dB
SNR_step = -1; % SNR step size
SNR = SNR_max:SNR_step:SNR_min;
power = 10.^(SNR/10);

% Define signal parameters
signal_length = 100; % Length of the signals
% Determine min and max power (over range of Bluetooth and its bounds)
% Ideally, between avg value (-20; 20) is for all Bluetooth
power_X = -10; % Power for bit 0
power_Y = 10; % Power for bit 1

std_th_minus = power_X;
std_th_plus = power_Y;

% Fixed threshold for authentication signal: assuming this is lower than
% the original signal, since auth + data gives received signal
std_th_auth_plus = +5;
std_th_auth_minus = -5;

% Initialize signals
data_signal = zeros(1, signal_length);
authentication_signal = zeros(1, signal_length);

% Generate data signal
binary_data = randi([0, 1], 1, signal_length); % Binary form
% "Real" form - Assigning to each bit its value of relativ power 
for i = 1:signal_length
    if binary_data(i) == 1
        data_signal(i) = power_Y;
    else
        data_signal(i) = power_X;
    end
end

% Generate authentication signal
binary_auth = randi([0, 1], 1, signal_length);
for i = 1:signal_length
    if binary_auth(i) == 1
        authentication_signal(i) = std_th_auth_plus;
    else
        authentication_signal(i) = std_th_auth_minus;
    end
end

% Plot of auth and data signals (utility)
% figure;
% subplot(2, 1, 1);
% plot(data_signal);
% title('Data Signal');
% xlabel('Time'); % assuming we send a bit each second
% ylabel('Power');
% 
% subplot(2, 1, 2);
% plot(authentication_signal);
% title('Authentication Signal');
% xlabel('Time');
% ylabel('Power');

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

% Initialize signal S
S = zeros(1, signal_length);

% Combine signals bit by bit
for i = 1:signal_length
    % Combine bits from data_signal and authentication_signal
    S(i) = data_signal(i) + authentication_signal(i);
end

% 10 (data bit 1) + (-5) (auth bit 0) = 5 (discordant bits)
% -10 (data bit 0) + (-5) (auth bit 0) = -15 (concordant bits)
% -10 (data bit 0) + (5) (auth bit 1) = 5 (discordant bits)

% Plot the combined signal (this is the sent signal) - utility once again
% figure;
% plot(S);
% title('Combined Signal (S)');
% xlabel('Time');
% ylabel('Power');

% Assuming center is 0 (given the signal is -10 and 10)
center = 0;

received_data=[];
received_auth=[];

wrong_auth_bits = 0;
wrong_data_bits = 0;

% Example of BER matrix (for auth wrong bits) to select dynamic
% thresholding encoding inside of the loop

% As of now, we keep this one

BER_auth_avg_final = [
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0004    0.0020    0.0050    0.0122    0.0248    0.0340    0.0584;
    0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0002    0.0002    0.0024    0.0068    0.0148    0.0234    0.0382    0.0632;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0004    0.0016    0.0038    0.0068    0.0144    0.0278    0.0398    0.0664;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0008    0.0024    0.0062    0.0126    0.0260    0.0382    0.0592;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0002    0.0026    0.0042    0.0116    0.0256    0.0330    0.0626;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0006    0.0022    0.0050    0.0110    0.0242    0.0342    0.0530;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0018    0.0026    0.0064    0.0154    0.0276    0.0402    0.0620;
    0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0004    0.0002    0.0032    0.0048    0.0148    0.0244    0.0486    0.0622;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0004    0.0020    0.0056    0.0128    0.0194    0.0340    0.0498;
    0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0004    0.0012    0.0018    0.0062    0.0126    0.0240    0.0384    0.0546;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0006    0.0006    0.0030    0.0066    0.0130    0.0252    0.0468    0.0698;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0010    0.0026    0.0056    0.0134    0.0236    0.0386    0.0606;
    0         0         0         0    0.0002    0.0002         0         0         0    0.0002         0         0         0         0    0.0010    0.0022    0.0070    0.0164    0.0264    0.0440    0.0618;
    0    0.0002    0.0004    0.0002    0.0002    0.0002         0    0.0004         0    0.0004    0.0006    0.0002         0         0    0.0002    0.0026    0.0054    0.0122    0.0200    0.0336    0.0502;
    0    0.0002    0.0016    0.0008    0.0002    0.0006    0.0018    0.0002    0.0004    0.0012    0.0006    0.0010    0.0010    0.0002    0.0004    0.0028    0.0054    0.0128    0.0246    0.0368    0.0612;
    0.0020    0.0024    0.0038    0.0024    0.0026    0.0022    0.0026    0.0032    0.0020    0.0018    0.0030    0.0026    0.0022    0.0026    0.0028    0.0028    0.0054    0.0142    0.0320    0.0488    0.0640;
    0.0050    0.0068    0.0068    0.0062    0.0042    0.0050    0.0064    0.0048    0.0056    0.0062    0.0066    0.0056    0.0070    0.0054    0.0054    0.0066    0.0084    0.0152    0.0238    0.0386    0.0620;
    0.0122    0.0148    0.0144    0.0126    0.0116    0.0110    0.0154    0.0148    0.0128    0.0126    0.0130    0.0134    0.0164    0.0122    0.0128    0.0142    0.0152    0.0126    0.0254    0.0396    0.0530;
    0.0248    0.0234    0.0278    0.0260    0.0256    0.0242    0.0276    0.0244    0.0194    0.0240    0.0252    0.0236    0.0264    0.0200    0.0246    0.0320    0.0238    0.0254    0.0198    0.0302    0.0510;
    0.0340    0.0382    0.0398    0.0382    0.0330    0.0342    0.0402    0.0486    0.0340    0.0384    0.0468    0.0386    0.0440    0.0336    0.0368    0.0488    0.0386    0.0396    0.0418    0.0592    0.0544;
    0.0584    0.0632    0.0664    0.0592    0.0626    0.0530    0.0620    0.0622    0.0498    0.0546    0.0698    0.0606    0.0618    0.0502    0.0612    0.0640    0.0620    0.0530    0.0486    0.0524    0.0552;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0004         0         0    0.0002    0.0002         0;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002         0         0    0.0002    0.0002         0    0.0006    0.0012;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0010    0.0006    0.0004    0.0008    0.0008    0.0008    0.0010;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0004    0.0002    0.0002    0.0010    0.0006    0.0004    0.0010    0.0008;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0030    0.0012    0.0034    0.0024    0.0024    0.0032;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0028    0.0030    0.0068    0.0062    0.0040    0.0088    0.0042;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0014    0.0054    0.0084    0.0132    0.0078    0.0136    0.0128;
    0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0002    0.0002    0.0018    0.0066    0.0150    0.0136    0.0258    0.0234;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0006    0.0030    0.0066    0.0122    0.0224    0.0384    0.0370;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0008    0.0012    0.0070    0.0120    0.0214    0.0378    0.0572;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0010    0.0010    0.0086    0.0142    0.0262    0.0414    0.0622;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0004    0.0002    0.0034    0.0058    0.0112    0.0214    0.0326    0.0508;
    0         0         0         0         0         0         0         0         0         0         0         0    0.0002         0    0.0002    0.0026    0.0070    0.0136    0.0270    0.0386    0.0644;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0010    0.0030    0.0086    0.0140    0.0220    0.0340    0.0578;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0012    0.0032    0.0042    0.0128    0.0264    0.0408    0.0576;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0010    0.0024    0.0044    0.0154    0.0252    0.0360    0.0616;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0006    0.0038    0.0074    0.0122    0.0218    0.0436    0.0520;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0026    0.0070    0.0126    0.0222    0.0386    0.0534;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0008    0.0030    0.0070    0.0120    0.0214    0.0378    0.0572;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0008    0.0014    0.0048    0.0112    0.0214    0.0326    0.0508;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0006    0.0010    0.0014    0.0056    0.0122    0.0270    0.0386    0.0644;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0010    0.0022    0.0092    0.0140    0.0220    0.0340    0.0578;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0014    0.0022    0.0056    0.0146    0.0264    0.0408    0.0576;
    0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0006    0.0028    0.0040    0.0112    0.0252    0.0360    0.0616;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0016    0.0028    0.0050    0.0128    0.0250    0.0346    0.0582;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0012    0.0012    0.0074    0.0112    0.0260    0.0328    0.0568;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0014    0.0018    0.0056    0.0122    0.0206    0.0386    0.0588;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0006    0.0010    0.0034    0.0078    0.0128    0.0256    0.0428    0.0558;
    0         0         0         0         0         0         0         0         0         0         0         0         0    0.0002    0.0010    0.0024    0.0062    0.0122    0.0204    0.0400    0.0596;
];

% Loop through each distance
for j = 1:max_distance
    % Loop through each SNR level
    for k = 1:length(SNR)
        % Initialize arrays to store received data and authentication bits
        received_data = zeros(1, signal_length);
        received_auth = zeros(1, signal_length);
        
        % Generate the received signal by adding AWGN
        received_signal = awgn(S, SNR(k));

        wrong_data_bits = 0;
        wrong_auth_bits = 0;

        %% FIXED THRESHOLDS
        
        % Loop through each bit in the received signal
        for i = 1:signal_length
            % Decode the received signal with fixed thresholds  
            % First, we decode the data and see the wrong bits for BER
            if received_signal(i) >= center 
                received_data(i) = 1;
                % Epsilon allows to retrieve error percentage - this value
                % is strictly dependent on the min/max value of auth
                % signal, given it's the smaller signal
                if round(received_signal(i)) == std_th_auth_plus
                    received_auth(i) = 0;                
                else
                    received_auth(i) = 1;                
                end
            elseif received_signal(i) < center
                received_data(i) = 0;
                if round(received_signal(i)) == std_th_auth_minus
                    received_auth(i) = 1;                
                else
                    received_auth(i) = 0;                
                end
            end
        end

        % Checking the wrong bits in both signals (Hamming distance)
        for i = 1:signal_length
            if received_data(i) ~= binary_data(i) 
                wrong_data_bits = wrong_data_bits + 1;
            end
            if received_auth(i) ~= binary_auth(i) 
                wrong_auth_bits = wrong_auth_bits + 1;
            end
        end

        % Calculate BER for the current iteration
        BER_data = wrong_data_bits / signal_length;
        BER_auth = wrong_auth_bits / signal_length;

        % Using BER in order to actually select the different encoding
        % method as desired
        if BER_auth > BER_auth_avg_final(j, k)
            %% VARIABLE THRESHOLDS
            
            % First, there is the variable thresholds settings
            
            % Assuming received_signal is already defined as a vector of values
            HH = max(received_signal);    % high high
            MH = max(received_signal)/2;  % medium high
            ML = min(received_signal)/2;  % medium low
            LL = min(received_signal);    % low low
            
            % Definition of nearest ML/LM variables
            % made to actually refine the finding of the 4 power values for
            % dynamic thresholding decoding
            nearest_MH = 0;
            nearest_ML = 0;
            
            for i = 1:length(received_signal)
                if received_signal(i) > center % assuming is 0 (in out case)
                    if nearest_MH == 0
                        nearest_MH = received_signal(i);  % first value
                    elseif abs(received_signal(i) - MH) < abs(nearest_MH - MH)
                        % MH is the theoretical midhigh point, then refined
                        % with the actual value when it is found between
                        % the actual high interval and the highest value
                        nearest_MH = received_signal(i);
                    end
                else
                    if nearest_ML == 0
                        nearest_ML = received_signal(i);  % first value
                    elseif abs(received_signal(i) - ML) < abs(nearest_ML - ML)
                        nearest_ML = received_signal(i);
                        % ML is the theoretical midlow point, then refined
                        % with the actual value when it is found between
                        % the actual low interval and the lowest value
                    end
                end
            end
            
            % Second, there is the actual decoding (names matching the drawing
            % in page 2 of 4 of Alessandro's notes of 24-04)
            
            T1 = HH;
            T2 = MH;
            T3 = ML;
            T4 = LL;
            
            % Loop through each bit in the received signal
            for i = 1:signal_length
                % Decode the received signal with fixed thresholds  
                % First, we decode the data and see the wrong bits for BER
                if received_signal(i) >= center 
                    received_data(i) = 1;
                elseif received_signal(i) < center
                    received_data(i) = 0;
                end
                % First the 0 encoding
                if received_data(i) == 1 && received_signal(i) < T2
                    received_auth(i) = 0;
                end
                if received_data(i) == 0 && received_signal(i) > T4
                    received_auth(i) = 0;
                end
                % Then, the 1 encoding
                if received_data(i) == 1 && received_signal(i) < T1
                    received_auth(i) = 1;
                end
                if received_data(i) == 0 && received_signal(i) > T3
                    received_auth(i) = 1;
                end
            end
        end
    end
end

%% TO DO - False alarm and missed detection
%% TO DO - Represent FA-MD as matrix form (distance x SNR)

% False alarm - authenticate signals
for j = 1:max_distance
    for k = 1:length(SNR)
        for f = 0.01:target_FA_rates
            
        end
    end
end

% Miss detection - non-authenticate signals
for j = 1:max_distance
    for k = 1:length(SNR)
        for f = 0.1:target_MD_rates
            
        end
    end
end
