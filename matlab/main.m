function [flss, pltResults, j] = main(explorerType, confidenceType, weightType, distType, swarmEnabled, swarmPolicy, freezePolicy, alpha, pointCloud, physical, rounds, removeAlpha, concurrentPolicy, crm, fixN, ff)

updatePlot = 1;
saveGif = updatePlot && 0;
showInitialPlots = 1;
showFinalPlot = 1;
saveResults = 0;

rng('default');
rng(1);

flss = FLS.empty(size(pointCloud, 2), 0);
screen = containers.Map('KeyType','char','ValueType','any');
dispatchers = {Dispatcher([0; 0]) Dispatcher([0; 0; 0])};

distModelSet = {FLSDistLinear() FLSDistSquareRoot()};
ratingSet = {FLSRatingNormalizedDistanceGTL() FLSRatingM() FLSRatingX() FLSRatingRandom()};

switch concurrentPolicy
    case 1
        concurrentSelector = @selectConcurrentExplorers;
    case 2
        concurrentSelector = @selectConcurrentExplorers2;
end

% ratingSet = containers.Map( ...
%     {'distTraveled', 'distGTL', 'distNormalizedGTL', 'obsGTLN', 'mN', 'eN', 'hN'}, ...
%     {FLSRatingDistanceTraveled(), ...
%     FLSRatingDistanceGTL(), ...
%     FLSRatingNormalizedDistanceGTL(), ...
%     FLSRatingObsGTLNeighbors(), ...
%     FLSRatingMissingNeighbors(), ...
%     FLSRatingErroneousNeighbors(), ...
%     FLSRatingNeighbors(.5, .5)} ...
%     );


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
            explorer = FLSExplorerDistAngle(freezePolicy);
        case 5
            explorer = FLSExplorerDistAngleAvg(freezePolicy);
        case 6
            explorer = FLSExplorerLoGlo(freezePolicy);
    end

    confidenceModel = ratingSet{confidenceType};
    weightModel = ratingSet{weightType};
    distModel = distModelSet{distType};
    swarm = FLSSwarm(swarmEnabled, swarmPolicy);

    fls = FLS(dispatcher.coord, point, alpha, weightModel, confidenceModel, distModel, explorer, swarm, crm, fixN, physical, screen);
    flss(i) = fls;
    fls.flyTo(point);
    fls.lastD = 0;
    fls.locked = 0;
    fls.distanceTraveled = 0;
    if removeAlpha
        fls.alpha = 0;
    end
    screen(fls.id) = fls;
end


% dH = hausdorff([flss.gtl], [flss.el]);
% fprintf("Hausdorff Distance: %f\n", dH);
% return;

if showInitialPlots
    plotScreen([flss.gtl], 'blue', 3*ff+2);
    plotScreen([flss.el], 'red', 3*ff+3);
end
% text2 = reportMetrics(flss);
% txt = sprintf("%s\n", text2);
% annotation('textbox',[.9 .7 .1 .2], ...
%     'String',txt,'EdgeColor','none')


if updatePlot
    h = plotScreen([flss.el], 'red', 3*ff+1);
end
gifName = sprintf('gif/relic%d.gif', ff);


pltResults = zeros(27, rounds);
tries = 0;


for j=1:rounds
    terminate = 0;
    fprintf('\nROUND %d:\n', j);

    if all([flss.freeze] == 1) 
        disp('  all FLS are freezed');
        for i = 1:size(flss, 2)
            flss(i).freeze = 0;
        end
        disp('  unfreezed all FLSs');
    end

    numFrozen = sum([flss.freeze]);
    fprintf('  %d FLS(s) are frozen\n', numFrozen);

    
    sumN = 0;
    maxN = -Inf;
    minN = Inf;
    
    for i = 1:size(flss, 2)
        fls = flss(i);

        if crm
            fls.adjustCR();
        elseif fixN
            fls.computeNeighbors(flss);
        end

        n = size(fls.elNeighbors, 2);

        sumN = sumN + n;
        if n > maxN
            maxN = n;
        end
        if n < minN
            minN = n;
        end
    end

    pltResults(19,j) = minN;
    pltResults(20,j) = sumN/size(flss, 2);
    pltResults(21,j) = maxN;


    candidateExplorers = selectCandidateExplorers(flss);
    numCandidate = size(candidateExplorers, 2);
    fprintf('  %d FLS(s) are less than 100 percent confident\n', numCandidate);

    if size(candidateExplorers, 2) < 1
        disp('  no FLSs is selected to move')

        if all([flss.freeze] == 0)
            terminate = 1;
        else
            for k = 1:size(flss, 2)
                flss(k).freeze = 0;
            end
        end
    end

    concurrentExplorers = concurrentSelector(candidateExplorers);
%     concurrentExplorers = flss;
    numConcurrent = size(concurrentExplorers, 2);
    fprintf('  %d FLS(s) are selected to adjust\n', numConcurrent);

    calSuccess = 0;
    specificEr = 0;
    for i = 1:size(concurrentExplorers, 2)
        s = concurrentExplorers(i).initializeExplorer();
        if s > 0
            calSuccess = calSuccess + s;
        elseif s == -1
            specificEr = specificEr + 1;
        end
    end
    
    calFail = numConcurrent - calSuccess;
    fprintf('  %d FLS(s) failed to compute v\n', calFail);
    fprintf('  %d FLS(s) computed v\n', calSuccess);

    anchors = [];
    sumL = 0;
%     while size(concurrentExplorers, 2)
        itemsToRemove = [];

        for i = 1:size(concurrentExplorers, 2)
            fls = concurrentExplorers(i);
            fls.exploreOneStep();
            itemsToRemove = [itemsToRemove fls];
        end

        movSuccess = 0;
        for i = 1:size(itemsToRemove, 2)
            fls = itemsToRemove(i);
            movSuccess = movSuccess + fls.finalizeExploration();
            if fls.explorer.neighbor ~= 0
                anchors = [anchors fls.explorer.neighbor];
            end
            sumL = sumL + fls.lastD;
        end
        fprintf('  %d FLS(s) have nonzero v\n', movSuccess);
        movZero = calSuccess - movSuccess;

%         concurrentExplorers = setdiff(concurrentExplorers, itemsToRemove);
%     end

    otherFlss = setdiff(flss, itemsToRemove);

    sumS = 0;
    countS = 0;
    for i = 1:size(otherFlss, 2)
        d = otherFlss(i).lastD;
        if d > 0
            countS = countS + 1;
            sumS = sumS + d;
        end
    end

    count = 0;
        sumD = 0;
        maxD = -Inf;
        minD = Inf;
        minC = Inf;

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

            if fls.confidence < minC
                minC = fls.confidence;
            end

         

            fls.locked = 0;
            fls.lastD = 0;

            if fls.confidence < 0.5
                M = fls.swarm.members;

                if size(M, 2) > 0    
                    for k = 1:size(M, 2)
                        M(k).swarm.removeMember(fls);
                    end
                    fls.swarm.members = [];

                    fprintf('  FLS %s was removed from its swarm\n', fls.id);
                end
            end
                    
        end

        [numSwarms, swarmPopulation] = reportSwarm(flss);
        fprintf('  %d swarm(s) with %s members exist\n', numSwarms, strjoin(string(swarmPopulation), ', '));

        dH = hausdorff([flss.gtl], [flss.el]);

        pltResults(1,j) = numFrozen;
        pltResults(2,j) = count;
        pltResults(3,j) = sumD / size(flss, 2);
        pltResults(4,j) = maxD;
        pltResults(5,j) = dH;
        pltResults(6,j) = sum([flss.confidence]) / size(flss,2);
        pltResults(7,j) = numCandidate;
        pltResults(8,j) = numConcurrent;
        pltResults(9,j) = calSuccess;
        pltResults(10,j) = calFail;
        pltResults(11,j) = movSuccess;
        pltResults(12,j) = movZero;
        pltResults(13,j) = minC;
        pltResults(14,j) = numSwarms;
        pltResults(15,j) = min(swarmPopulation);
        pltResults(16,j) = mean(swarmPopulation);
        pltResults(17,j) = max(swarmPopulation);
        pltResults(18,j) = minD;
        pltResults(22,j) = max(0,size(anchors,2) - size(unique(anchors),2));
        if numConcurrent == 0
            pltResults(23,j) = 0; % avg d localizing
        else
            pltResults(23,j) = sumL / movSuccess; % avg d localizing
        end
        if countS == 0
            pltResults(24,j) = 0; % avg d swarm
        else
            pltResults(24,j) = sumS / countS; % avg d swarm
        end
        [s, avgE, avgC] = reportMetrics(flss);
        pltResults(25,j) = avgE;
        pltResults(26,j) = avgC;


        fprintf('  %d FLS(s) moved\n', count);
        if count
            fprintf('   min: %f\n   avg %f\n   max %f\n', minD, sumD/count, maxD);
        end


    s = fls.swarm.getAllMembers([]);
    allInOneSwarm = size(s,2) == size(flss,2);

    if updatePlot
        updateScreen(h, [flss.el]);
    end

    if saveGif
        exportgraphics(gcf,gifName,'Append',true);
    end

    if allInOneSwarm || terminate
        fprintf("Hausdorff Distance: %f\n", dH);

        tries = 1 + tries;

        if dH < 1 || tries == 2
            if allInOneSwarm 
                disp('all FLSs are in one swarm');
            else
                for i = 1:size(flss,2)
                    flss(1).swarm.addMember(flss(i));
                    flss(i).swarm.addMember(flss(1));
                end
            end
            break;
        else
            % reset swarms
            for i = 1:size(flss,2)
                flss(i).swarm.members = [];
            end
        end
    end
end



for k=1:size(pltResults,1)
    for i=j:rounds
        pltResults(k,i) = pltResults(k,j);
    end
end


% text1 = sprintf("Number of neighbors:\nmin: %d\navg: %f\nmax: %d\nrounds: %d",pltResults(19,1),pltResults(20,1),pltResults(21,1), j);
text2 = reportMetrics(flss);
dH = hausdorff([flss.gtl], [flss.el]);
txt = sprintf("%s\n%s\nHausdorff Distance: %f\n", '', text2, dH);


if showFinalPlot
    figure(3*ff+1);
    clf
    plotScreen([flss.el], 'black', 3*ff+1);
    annotation('textbox',[.67 .7 .2 .2], ...
        'String',txt,'EdgeColor','none');
else
    disp(txt);
end


if saveResults
    fileName = sprintf('result%d.mat', ff);
    save(fileName, 'pltResults');
end

end

