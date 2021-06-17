% Initializations
NUM_RUNS = 50;
pacMeansAll = {};
pacRunsAll = {};
pacConfidencesAll = {};

% Run the scenario NUM_RUNS times, to account for randomness in the communication channel
for runNum = 1:NUM_RUNS
    [pACts, allPACs] = adaptFPV(dOInit, vD);
    if runNum == 1
       runPACs = zeros(NUM_RUNS, numel(pACts));
    end
    runPACs(runNum, :) = allPACs;
end

% Calculate the mean probability of avoiding collision and the confidence intervals, at each time instant
for t = 1:numel(pACts)
      pacMeans = [pacMeans; mean(runPACs(:,t))];
      [lowerConf, upperConf] = calculate99PercConfidenceInterval(runPACs(:, t));
      pacConfidences = [pacConfidences, lowerConf, upperConf];
end

% Calculate the degree of safety
degreeOfSafety = calculateSigma(pacMeans, pACts, dOInit, velocity);

% Display results
FONT_SIZE = 16;
LINE_WIDTH = 3;
figure
plot(pACts, pacMeans, 'LineWidth', LINE_WIDTH);
hold on;
grid on;
xlabel("Time instant (s)");
ylabel("Instantaneous probability of avoiding collision");
ylim([0, 1.0]);
set(gca,'FontSize', FONT_SIZE);

disp(strcat("The degree of safety in this scenario is :", num2str(degreeOfSafety)));