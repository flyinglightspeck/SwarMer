function flss = main2(explorerType, confidenceType, weightType, distType, swarmEnabled, swarmPolicy, freezePolicy, alpha, pointCloud, physical, rounds, removeAlpha, concurrentPolicy, crm, fixN, ff, swarmerPolicy, binary, label)

rng('default');
rng(1);

flss = FLS.empty(size(pointCloud, 2), 0);
screen = containers.Map('KeyType','char','ValueType','any');
dispatchers = {Dispatcher([0; 0]) Dispatcher([0; 0; 0])};

distModelSet = {FLSDistLinear() FLSDistSquareRoot()};
ratingSet = {FLSRatingNormalizedDistanceGTL() FLSRatingM() FLSRatingX() FLSRatingRandom() FLSRatingMissingNeighbors()};

random = 0;
continuous = 1;
showLocalizing = 1;
F = [];

for i = 1:size(pointCloud, 2)
    point = pointCloud(:,i);
    dispatcher = selectDispatcher(point, dispatchers);

    switch explorerType
        case 1
            explorer = FLSExplorerTriangulation(freezePolicy);
        case 2
            explorer = FLSExplorerTrilateration(freezePolicy);
        case 3
            explorer = FLSExplorerTriangulation(freezePolicy);
        case 4
            explorer = FLSExplorerDistAngle2(freezePolicy);
        case 5
            explorer = FLSExplorerDistAngleAvg(freezePolicy);
        case 6
            explorer = FLSExplorerLoGlo(freezePolicy);
    end

    confidenceModel = ratingSet{5};
    weightModel = ratingSet{5};
    distModel = distModelSet{distType};
    swarm = FLSSwarm(swarmEnabled, swarmPolicy);

    fls = FLS(dispatcher.coord, point, alpha, weightModel, confidenceModel, distModel, explorer, swarm, crm, 1, physical, screen);
    flss(i) = fls;
    if random
        fls.el = [rand*100; rand*100; rand*100];
    else
        fls.flyTo(point);
    end
    fls.lastD = 0;
    fls.d0 = 0;
    fls.d1 = 0;
    fls.d2 = 0;
    fls.d3 = 0;
    fls.locked = 0;
    fls.visited = 0;
    fls.distanceTraveled = 0;
    if removeAlpha
        fls.alpha = 0;
    end
    screen(fls.id) = fls;
end

color3 = [51 182 121]/255;
color2 = [4 155 229]/255;
color1 = [142 36 170]/255;
color4 = [240 147 0]/255;

% plotScreen([flss.gtl], 'blue', 3*ff+1);
% 
% plotScreen([flss.el], 'red', 3*ff+2);

pltResults = zeros(31, rounds);
tries = 0;

dH = hausdorff([flss.gtl], [flss.el]);
txt = sprintf("HD: %.2f\n", dH);

h = plotScreen([flss.el], 'green', 2*ff+1);
h.CData = color3;
set(gcf, 'Position',  [0 0 1280 720]);
axis([0 30 0 30]);
% axis([-5 105 -5 65]);
set(gca, 'Position', [0.005 0.11 0.775 0.815]);
view([0 90]);
fn = sprintf('gif/swarMer-%s-%d', label, ff);
gifName = sprintf('%s.gif', fn);
aviName = sprintf('%s.avi', fn);

hCopy = copyobj(h, gca); 
% replace coordinates with NaN 
% Either all XData or all YData or both should be NaN.
set(hCopy(1),'XData', NaN', 'YData', NaN)

if showLocalizing
l=legend(hCopy);
l.String = 'Localizing FLSs';
l.FontSize = 20;
end
h.CData = color1;



roundAnn = annotation('textbox',[.775 .6 .3 .3], 'String',sprintf("Round ID: %d", 0),'EdgeColor','none', 'FontSize', 28);
HDAnn = annotation('textbox',[.775 .5 .3 .3], 'String',txt,'EdgeColor','none', 'FontSize', 28);
NoSwarmAnn = annotation('textbox',[.775 .4 .3 .3], 'String',sprintf("No. of Swarms: %d", length(flss)),'EdgeColor','none', 'FontSize', 28);
NoThawAnn = annotation('textbox',[.775 .3 .3 .3], 'String',sprintf("Thaw Swarms: %d", 0),'EdgeColor','none', 'FontSize', 28);

% figure(4);
% s=scatter(pointCloud(1,:), pointCloud(2,:), 'red', 'filled');
% axis square;


firstFrame = getframe(gcf);
F = [F firstFrame];

sView = [0 90];
eView = [-37.5 30];
dV = (eView-sView)/10;
sRound = 100;

for j=1:rounds
    terminate = 0;

%     plotScreen([flss.el], 'red', 2*ff+1);
%     hold on
    fprintf('\nROUND %d:\n', j);

    if binary
        concurrentExplorers = selectConcurrentExplorers4(flss);
        minMS = 2;
        avgMS = 2;
        maxMS = 2;
    else
        [concurrentExplorers, minMS, avgMS, maxMS, totalMS, mergingToBusySwarm] = selectConcurrentExplorersSwarMer3(flss, swarmerPolicy);
        pltResults(30,j) = mergingToBusySwarm;
        pltResults(31,j) = totalMS;
    end

    numConcurrent = size(concurrentExplorers, 2);
    fprintf('  %d FLS(s) are selected to adjust\n', numConcurrent);


    if showLocalizing
    c = repmat(color1,[length(flss) 1]);
%     M = repmat('o', [1 length(flss)]);
    % c is now a 5x3 containing 5 copies of the original RGB
    for q=1:numConcurrent
    idx = find(flss==concurrentExplorers(q));
    c(idx,:) = color3;
%     M(idx) = '^';
    end
    % c now contains red, followed by 4 copies of the original color

    h.CData = c;
%     h.Marker = M;
    % Now the scatter object is using those colors
    drawnow
    end

    anchors = [];
    sumL = 0;
    movSuccess = 0;
    calSuccess = 0;

    for i = 1:numConcurrent
        s = concurrentExplorers(i).initializeExplorer();
        if s > 0
            calSuccess = calSuccess + s;
        end
        fls = concurrentExplorers(i);
        fls.exploreOneStep();
        movSuccess = movSuccess + fls.finalizeExploration();
        sumL = sumL + fls.lastD;
        anchors = [anchors fls.explorer.neighbor];
    end

    
    calFail = numConcurrent - calSuccess;
    fprintf('  %d FLS(s) failed to compute v\n', calFail);
    fprintf('  %d FLS(s) computed v\n', calSuccess);

    fprintf('  %d FLS(s) have nonzero v\n', movSuccess);
    movZero = calSuccess - movSuccess;

    count = 0;
    sumD = 0;
    maxD = -Inf;
    minD = Inf;

    [text2, avgE, avgC] = reportMetrics(flss);
    pltResults(25,j) = avgE; % average error
    pltResults(26,j) = avgC;

    for i = 1:size(flss, 2)
        fls = flss(i);
        d = fls.lastD;

        if d > 0
            count = count + 1;
            sumD = sumD + d;
        end

        if d > maxD
            maxD = d;
        end
        if d < minD
            minD = d;
        end

     

        fls.locked = 0;
        fls.lastD = 0;
        fls.freeze = 0;
        fls.visited = 0;
    end

    [numSwarms, swarmPopulation] = reportSwarm(flss);
    fprintf('  %d swarm(s) with %s members exist\n', numSwarms, strjoin(string(swarmPopulation), ', '));


    [uniqAnchors,~,ix] = unique(anchors);
    C = accumarray(ix,1).';
    C=C(C~=1);

    pltResults(2,j) = count; % number of all moveing FLSs
    pltResults(3,j) = sumD/count; % avg distance traveled by al FLSs
    pltResults(4,j) = maxD;
    pltResults(1,j) = minMS; % min number of merged swarms
    pltResults(6,j) = avgMS; % avg number of merged swarms
    pltResults(7,j) = maxMS; % max number of merged swarms
    pltResults(8,j) = numConcurrent; % number of localizing FLSs
    pltResults(9,j) = calSuccess;
    pltResults(10,j) = calFail;
    pltResults(11,j) = movSuccess;
    pltResults(12,j) = movZero;
    pltResults(14,j) = numSwarms; % number of swarms
    pltResults(15,j) = min(swarmPopulation);
    pltResults(16,j) = mean(swarmPopulation); % average population of swarms
    pltResults(17,j) = max(swarmPopulation);
    pltResults(18,j) = length(uniqAnchors); % number of anchors
    pltResults(22,j) = length(C); % number of shared anchors
    
    if isempty(C)
        pltResults(13,j) = 0;
        pltResults(28,j) = 0;
        pltResults(29,j) = 0; 
    else
        pltResults(13,j) = mean(C); % average number of localizing flss per shared anchors
        pltResults(28,j) = min(C); % min number of localizing flss per shared anchors
        pltResults(29,j) = max(C); % max number of localizing flss per shared anchors
    end

    if numConcurrent == 0
        pltResults(23,j) = 0;
    else
        pltResults(23,j) = sumL / movSuccess; % avg distance traveled by localizing FLSs
    end

    if count - movSuccess == 0
        pltResults(27,j) = sumD / count;
    else
        pltResults(27,j) = (sumD - sumL) / (count - movSuccess); % average distance traveled by swarms
    end


    dH = hausdorff([flss.gtl], [flss.el]);
    pltResults(5,j) = dH;

    fprintf('  %d FLS(s) moved\n', count);

    if j > sRound
        sV = sView + (j-sRound-1)*dV;
    else
        sV = 0;
    end


    if continuous
        frames = updateScreenContinuously(h, [flss.el], gifName, sV, dV);
    else
        updateScreen(h, [flss.el]);
    end
    F = [F frames];
    HDAnn.String = sprintf("HD: %.2f", dH);
    roundAnn.String = sprintf("Round ID: %d", j);
    NoSwarmAnn.String = sprintf("No. of Swarms: %d", numSwarms);
    NoThawAnn.FontWeight = "normal";

%     exportgraphics(gcf,gifName,'Append',true);
    if showLocalizing
    h.CData = color1;
    drawnow;
    end
    finalFrame = getframe(gcf);
    
    F = [F finalFrame];

    

%     s = fls.swarm.getAllMembers([]);
%     || numConcurrent == 0
    if numSwarms == 1 && swarmPopulation == length(flss)
        disp('all FLSs are in one swarm')
        
        fprintf("Hausdorff Distance: %f\n", dH);

        tries = 1 + tries;
        if dH < 0.09
            break;
        end
        if tries == 5
            break;
        end

        for i = 1:size(flss,2)
            flss(i).swarm.members = [];
        end
        NoSwarmAnn.String = sprintf("No. of Swarms: %d", length(flss));
        NoThawAnn.String = sprintf("Thaw Swarms: %d", tries);
        NoThawAnn.FontWeight = "bold";
    end


%     figure(4);
%     set(s, 'XData', pointCloud(1,:), 'YData', pointCloud(2,:));
%     s=scatter3(pointCloud(1,:), pointCloud(2,:), pointCloud(3,:), color, 'filled');

end


figure(2*ff+2);
clf

text1 = sprintf("rounds: %d\nnumber of swarm resets: %d\n", j, tries-1);

dH = hausdorff([flss.gtl], [flss.el]);
txt = sprintf("%s\n%s\nHausdorff Distance: %f\n", text1, text2, dH);

plotScreen([flss.el], 'black', 2*ff+2)
annotation('textbox',[.7 .7 .3 .3], ...
    'String',txt,'EdgeColor','none')

% fileName = sprintf('resultSwarmer-%d-%d.mat', ff, alpha);

fileName = sprintf('resultSwarmer-%s-%d.mat', label, alpha);

% save(fileName, 'pltResults');

writerObj = VideoWriter(fn, 'MPEG-4');
writerObj.FrameRate = 10;

totalFrames=length(F);
llff=F(totalFrames);
for k=1:9
    F=[F(1) F llff];
end

open(writerObj);
for i=1:length(F)
    % convert the image to a frame
    frame = F(i);    
    writeVideo(writerObj, frame);
   
end
% close the writer object
close(writerObj);

end

