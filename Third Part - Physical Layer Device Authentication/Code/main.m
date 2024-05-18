clear all;
clc;

% Set the number of iterations
N = 50;

% Set the simulation parameters
n_rounds = 50;
max_distance = 50;
signal_length = 100;
SNR_min = 10;
SNR_max = 30;
SNR_step = -1;

% Initialize arrays to store the BER values for each iteration
BER_data_all = zeros(max_distance, length(SNR_max:SNR_step:SNR_min), N);
BER_auth_all = zeros(max_distance, length(SNR_max:SNR_step:SNR_min), N);

% Perform iterations
for i = 1:N
    [BER_data_avg, BER_auth_avg] = ber_simulation(n_rounds, max_distance, signal_length, SNR_min, SNR_max, SNR_step);
    BER_data_all(:, :, i) = BER_data_avg;
    BER_auth_all(:, :, i) = BER_auth_avg;
end

% Compute the average of all collected matrices
BER_data_avg_final = mean(BER_data_all, 3);
BER_auth_avg_final = mean(BER_auth_all, 3);

% Display the final average BER values
disp('Final Average BER Data:');
disp(BER_data_avg_final);
disp('Final Average BER Auth:');
disp(BER_auth_avg_final);