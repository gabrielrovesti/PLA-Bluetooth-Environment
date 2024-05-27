%% ROC CURVE - FALSE ALARM VS MISSED DETECTION

% Extract FA and MD matrices from both FA/MD converrting them as functions,
% then plot

% FA_matrix = ...
% MD_matrix = ...

% Convert FA and MD matrices to rates
FA_rate_matrix = FA_matrix / N;
MD_rate_matrix = MD_matrix / N;

% Initialize variables to store average FA and MD rates for each SNR
avg_FA_rates = zeros(1, length(SNR));
avg_MD_rates = zeros(1, length(SNR));

% Calculate average FA and MD rates for each SNR
for k = 1:length(SNR)
    avg_FA_rates(k) = mean(FA_rate_matrix(:, k));
    avg_MD_rates(k) = mean(MD_rate_matrix(:, k));
end

% Plot ROC curve
figure;
plot(avg_FA_rates, avg_MD_rates, 'o-', 'LineWidth', 2);
xlabel('False Alarm Rate');
ylabel('Missed Detection Rate');
title('ROC Curve - False Alarm vs Missed Detection');
legend('ROC Curve', 'Location', 'best');
grid on;