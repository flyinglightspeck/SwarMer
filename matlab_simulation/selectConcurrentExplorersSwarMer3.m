% Final n-ary

function [flss, minMS, avgMS, maxMS, totalMS, mergingToBusySwarm] = selectConcurrentExplorersSwarMer3(allFlss, policy)
    mergingSwarmCount = [];
    n = size(allFlss,2);
    flss = [];
    minNumberOfNeighbors = 5;
    mergingToBusySwarm = 0;

%     Policies: 
%     1. Largest swarm as the anchor
%     2. Smallest swarm as the anchor
%     3. Swarm with the smallest Swarm-ID as the anchor
%     4. Swarm of the expanding FLS as the anchor.
%     5. Random
%     policy = 1;

    for i = 1:n
        fls = allFlss(i);
        
        if fls.freeze == 1 || fls.visited == 1
            continue;
        end

        swarm = fls.swarm.getAllMembers([fls]);

        for q=1:length(swarm)
            swarm(q).visited = 1;
        end

        paired = 0;
        k = 0;
        while ~paired
            k = k+1;
            for j=1:length(swarm)
                flsj = swarm(j);
                knn = getKNN(flsj, allFlss, minNumberOfNeighbors+k);
                missingN = knn(~ismember(knn, swarm));
                missingAN = missingN(~[missingN.freeze]);
    
                if ~isempty(missingAN)
                    misingS = [];
                    maxP = length(swarm);
                    sid = sort([swarm.id]);
                    maxID = sid(1);
                    maxPFls = flsj;
    
                    for k=1:length(missingAN)
                        mFls = missingAN(k);
                        if ~mFls.freeze
                            mSwarm = mFls.swarm.getAllMembers([mFls]);
                            for q=1:length(mSwarm)
                                mSwarm(q).freeze = 1;
                            end
                            misingS = [misingS mFls];
                            switch policy
                                case 1
                                    if length(mSwarm) > maxP
                                        maxP = length(mSwarm);
                                        maxPFls = mFls;
                                    end
                                case 2
                                    if length(mSwarm) < maxP
                                        maxP = length(mSwarm);
                                        maxPFls = mFls;
                                    end
                                case 3
                                    sid = sort([mSwarm.id]);
                                    sid = sid(1);
                                    if sid < maxID
                                        maxID = sid;
                                        maxPFls = mFls;
                                    end
                            end
                        end
                    end
                    
                    if ~isempty(misingS)
                        
                        localizingCandidates = [misingS flsj];
    
                        if policy == 5
                            maxPFls = randsample(localizingCandidates,1);
                        end

                        mergingSwarmCount = [mergingSwarmCount length(localizingCandidates)];
    
                        for p=1:length(localizingCandidates)
                            lFls = localizingCandidates(p);
                            if lFls.id == maxPFls.id
                                continue;
                            end
                            lFls.celNeighbors = maxPFls;
                            flss = [flss lFls];
                        end
    
                        for q=1:length(swarm)
                            swarm(q).freeze = 1;
                        end
    
                        paired = 1;
                        break;
                    end
    
                elseif ~isempty(missingN)
                    mergingToBusySwarm = mergingToBusySwarm + 1;
                    anchor = missingN(1);
                    flsj.celNeighbors = anchor;
                    flss = [flss flsj];

                    mSwarm = anchor.swarm.getAllMembers([anchor]);
                    for q=1:length(mSwarm)
                        mSwarm(q).freeze = 1;
                    end
    
                    mergingSwarmCount = [mergingSwarmCount 2];
    
                    for q=1:length(swarm)
                        swarm(q).freeze = 1;
                    end
    
                    paired = 1;
                    break;
                end
            end
        end
    end

%     disp(mergingSwarmCount);

    if isempty(mergingSwarmCount)
        mergingSwarmCount = [0];
        totalMS = 0;
    else
        totalMS = sum(mergingSwarmCount-1);
    end

    minMS = min(mergingSwarmCount);
    avgMS = mean(mergingSwarmCount);
    maxMS = max(mergingSwarmCount);
end




