clear
clc
close all;

% Parameter Initialization
verbose = 3; % verbose = 0: no visual output, 1: only visual output in the end, 2: all visual output
%verbose = 0; % verbose = 0: no visual output, 1: estimates and/or odometry and/or groundtruth, 2: (1)+ extra info, 3: (2)+ observation lines

ITERATIONS = 200;
CONVERGE = 1e-5;
PAUSEDURATION = 1 / 1000; % Seconds
windowSize = 5;
outlier = 0;


% this is the output of the simlator but is the input to the SLAM
% program.  It summarizes the simulated measurements based on the map and trajectory. 
%We mainly want to grab the odometry that was generated by the simulation add some 
% estimated covariance to it and use it to make motion factors.  
%Then use the range and bearing to landmarks to make factors between poses
%and landmarks.  

%Coment out all but one pair of files

%A small map with four landmarks 
% simOutFile = 'so_sym2_nk.txt';
% mapFile = 'map_sym2.txt';

% a larger, denser map but less noise
% simOutFile = 'so_o3_ie.txt';
% mapFile = 'map_o3.txt';

%A small map with five landmarks 
% simOutFile = 'so_sym3_nk.txt';
% mapFile = 'map_sym3.txt';


% here the noise is so large that you will not get convergence without
% modifications to the approach (for example outlier detection)
simOutFile = 'so_pb_10_outlier.txt';
mapFile = 'map_pent_big_10.txt';

% here we have no odometry at all so the initial estimate can not be made
% beyond the features seen at the start  It is intersting to see the local
% % minima it finds.
% simOutFile = 'so_pb_40_no.txt';
% mapFile = 'map_pent_big_40.txt';



% This init mainly just choses a good starting value for R the odometery 
% covariance and Q the range bearing Covariance base on the filename.             
[muRob0,sigma,R,Q,~] = init(simOutFile);
E_T = 2048;
B = 0.35;
R_L = 0.1;
R_R = 0.1;

%%
% Code initialization
datasetBase = 'DataSets/';
%Start by reading in the true map into a matrix
d = load([datasetBase mapFile]);

map = d(:,2:3)';
%map = cat(1,map,d(:,1)'); % Add id of the landmarks to map matrix
mapIds = d(:,1)';

% Now for the measurment data we have different lengths for each line in
% the file so we must work harder to load them line by line.
fid = fopen([datasetBase simOutFile],'r');
if fid <= 0
  fprintf('Failed to open simoutput file "%s"\n',simOutFile);
  return
end

simSteps = {};
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break
    end
    values = sscanf(line, '%f');
    %notice that we call the creator from the SimStep Class here to parse
    %this into a 'SimStep' object.
    simSteps = {simSteps{:} SimStep(values)}; %#ok
end
fclose(fid);

%%
% Graph SLAM initialize a set of pose nodes at poses in muRob bsed on the
%odometry alone. 
numPoses = size(simSteps,2);
odo = odometry(simSteps,E_T,B,R_L, R_R);
muRob = graph_slam_initialize(simSteps, muRob0,odo);
muMap = zeros(size(map));
% For plotting results
truePose = zeros(3, size(simSteps, 2));
odometry = truePose;
for i = 1:size(simSteps, 2)
    truePose(:,i) = simSteps{i}.truePose;
    odometry(:,i) = simSteps{i}.odometry;
end
finish=[1, numPoses];
% 
% temp=round(numPoses/8,0);
% finish=[1,temp*[1:7], numPoses];

for subpart=1:size(finish,2)-1
% Group robot poses that have seen the same landmark j (function is defined
% in aux folder)  This tau uses the known data associations and is to be 
% later used  in the optimizer.
% We also initialize the map to the first time each landmark is seen
% to where it was according to the odometry.
for j=1:finish(subpart)
    %We use previous loop's estiate instead of odometry to initialize muMap
    simSteps{j}.odometry=muRob(:,j);
end
muRob=[muRob zeros(3,finish(subpart+1)-size(muRob,2))];
for t=(finish(subpart)+1):finish(subpart+1)
        a=muRob(3,t-1);
        du = [odo(1,t-1)*cos(a);
        odo(1,t-1)*sin(a);
        odo(2,t-1)];      
        muRob(:,t)=muRob(:,t-1)+du;
        simSteps{t}.odometry=muRob(:,t);    
end    
[tau muMap]= createTau(mapIds, simSteps,odo,finish(subpart+1));

%%
% Graph SLAM main loop
graphSlam = figure('Name','GraphSLAM');
diff = [];
stateChanges = zeros(1, windowSize);
hold on 
plot_graph_slam(muRob,muMap,map,truePose,odometry,true,true,true,true,true,true);
title('Initial Map and Trajectory  (in Red)');
 subpart
%pause
for it = 1:ITERATIONS
    % Save previous estimate
    prevMuRob = muRob(:,1:finish(subpart+1));
    
    % Graph SLAM linearize
    [Omega, Xi] = graph_slam_linearize(muRob, simSteps, muMap, R, Q, mapIds, odo,finish(subpart+1));
  
    % Graph SLAM reduce
    [OmegaRed, XiRed] = graph_slam_reduce(Omega, Xi, tau, mapIds);
    OmegaRed(:,:,3,3)
    XiRed(:,3)'
%     pause  
    % Graph SLAM solve robot
    [muRob, SigmaRob] = graph_slam_solve_rob(OmegaRed, XiRed);
    
%     % GraphSLAM solve map
%     if verbose >= 2 || it == ITERATIONS
%         [muMap] = graph_slam_solve_map(muRob, Omega, Xi, tau, mapIds);
%     end
    % Update diff. between current and previous estimate
    currentDiff = prevMuRob - muRob;
    currentDiff(3,:) = mod(currentDiff(3,:)+pi,2*pi)-pi;
    currentDiff = abs(sum(sum(currentDiff)));
    
    % Compute error between current estimate and ground truth
    globalError = truePose(:,1:finish(subpart+1)) - muRob(:,1:finish(subpart+1));
    globalError(3,:) = mod(globalError(3,:)+pi,2*pi)-pi;
    diff = [diff abs(sum(sum(globalError)))/finish(subpart+1)];
    
    % outlier check and process
    stateChanges = [stateChanges(2:end), currentDiff];
    
    % calculate dynamic threshold
    if it > windowSize
        dynamicThreshold = mean(stateChanges) + 0.01*std(stateChanges);
        % check the outlier estimation
        if currentDiff > dynamicThreshold
            muRob = prevMuRob;
            outlier = outlier + 1;
        end
    end


    % GraphSLAM solve map
    if verbose >= 2 || it == ITERATIONS
        [muMap] = graph_slam_solve_map(muRob, Omega, Xi, tau, mapIds);
    end
    
    % Check if it has converged
    if  currentDiff <= CONVERGE
        if verbose < 2
            [muMap] = graph_slam_solve_map(muRob, Omega, Xi, tau, mapIds);
        end
        break;
    end


    % Plot gth and recovered maps
    if verbose >= 2
        clf;
        hold on 
        plot_graph_slam(muRob,muMap,map,truePose,odometry,true,true,true,true,true,true);
       title(it);
        pause(PAUSEDURATION);
    end
end
hold off


fprintf('\n');

%%
% Plot gth and recovered maps
if verbose >= 1
    close all;
    hold on 
    plot_graph_slam(muRob,muMap,map,truePose,odometry,true,true,true,true,true,true);
    title('Final Map and Trajectory')
    hold off
end

%%
% Plot the error

steps = size(simSteps,2);
if steps>finish(subpart+1)
    steps=finish(subpart+1);
end
errpose = zeros(3, steps);
for i = 1:steps
    errpose(:,i) = simSteps{i}.truePose(:) - muRob(:,i);
    errpose(3,i) = mod(errpose(3,i)+pi,2*pi)-pi;
end

maex = mean(abs(errpose(1,:)));
mex = mean(errpose(1,:));
maey = mean(abs(errpose(2,:)));
mey = mean(errpose(2,:));
maet = mean(abs(errpose(3,:)));
met = mean(errpose(3,:));
display(sprintf('mean error(x, y, theta)=(%f, %f, %f)\nmean absolute error=(%f, %f, %f)\n',mex,mey,met, maex,maey,maet));

if verbose >= 1
    figure('Name', 'GraphSLAM: Pose error vs travel time');
    clf;
    subplot(3,1,1);
    plot(errpose(1,:));
    title(sprintf('error on x, mean error=%f, mean absolute err=%f',mex,maex));
    subplot(3,1,2);
    plot(errpose(2,:));
    title(sprintf('error on y, mean error=%f, mean absolute err=%f',mey,maey));
    subplot(3,1,3);
    plot(errpose(3,:));
    title(sprintf('error on theta, mean error=%f, mean absolute err=%f',met,maet));

    figure('Name', 'GraphSLAM: Sigma');
    clf;
    subplot(3,1,1);
    plot(squeeze(SigmaRob(1,1,:,:)));
    title('\Sigma(1,1)');
    subplot(3,1,2);
    plot(squeeze(SigmaRob(2,2,:,:)));
    title('\Sigma(2,2)');
    subplot(3,1,3);
    plot(squeeze(SigmaRob(3,3,:,:)));
    title('\Sigma(3,3)');
    
    figure('Name', 'GraphSLAM: global error');
    clf;
    plot(diff);
end
end