function map = compareResults()
%     
    load(sprintf('resultSwarmer-%s-%d.mat','D-N',1), 'pltResults');
    result1=pltResults(:,1:5);

    load(sprintf('resultSwarmer-%s-%d.mat','D-N',3), 'pltResults');
    result2=pltResults(:,1:15);

    load(sprintf('resultSwarmer-%s-%d.mat','D-N',5), 'pltResults');
    result3=pltResults(:,1:21);

%     plotResults('', 1, result1(30,:), 'dragon', result2(30,:), 'hat', result3(30,:), 'skateboard');
%     plotResults('', 2, result2(31,:), '', result2(30,:), '');
%     plotResults('', 3, result3(31,:), '', result3(30,:), '');

%     y=ylabel('Number of swarms');
%     ylim tickaligned
%     xlim padded
% 
%     t = title(' ');
%     tpos = get(t, 'Position');
%     ypos = get(y, 'Position');
%     set(y, 'Position', [0 tpos(2) ypos(3)], 'Rotation', 0, 'HorizontalAlignment', 'left')
% 
%     xlabel('Rounds (Time)');
% return;
% 
keySet = {5,14,16,8,18,22,23,27,1,6,7,13,3};
valueSet = [
    "Hd" ...
    "Number of swarms" ...
    "Average Population of Swarms" ...
    "Number of Localizing FLSs" ...
    "Number of Anchors" ...
    "Number of Shared Anchors" ...
    "Average Dead Reckoning Distance Traveled by Localizing FLSs" ...
    "Average Dead Reckoning Distance Traveled by Swarms"...
    "min number of merged swarms"...
    "avg number of merged swarms"...
    "max number of merged swarms"...
    "average number of localizing flss per shared anchors"...
    "Average Dead Reckoning Distance Traveled by All FLSs"];

lablesValueSet = [
    "Hausdorff distance" ...
    "Number of swarms" ...
    "Population" ...
    "Number of localizing FLSs" ...
    "Number of anchor FLSs" ...
    "Number of shared anchor FLSs" ...
    "Avg distance (cells)" ...
    "Avg distance (cells)"...
    "Number of swarms"...
    "Number of swarms"...
    "Number of swarms"...
    "Avg number of localizing FLSs"...
    "Avg distance (cells)"];

map = containers.Map(keySet,valueSet);
lablesMap = containers.Map(keySet,lablesValueSet);
% 

keys = [5 7];

for i=1:1
    key = keys(i);
    titlet = map(key);
%     plotResults(titlet, key, result1(key,:), 'dragon', result2(key,:), 'race car', result3(key,:), 'statue');
    plotResults(titlet, key, result1(key,:), '\epsilon=1^{\circ}', result2(key,:), '\epsilon=3^{\circ}', result3(key,:), '\epsilon=5^{\circ}');
%     plotResults(titlet, key, result1(key,:)./result1(2,:), '\epsilon=1^{\circ}');

    txt = lablesMap(key);
    y=ylabel(txt, 'FontSize', 14);
    ylim tickaligned
    ylim([0 6])

    xlim padded
    t = title(' ');
    tpos = get(t, 'Position');
    ypos = get(y, 'Position');
    set(y, 'Position', [0 tpos(2) ypos(3)], 'Rotation', 0, 'HorizontalAlignment', 'left')

    xlabel('Rounds (Time)', 'FontSize', 14);
    
    ax=gca;
    ax.FontSize = 13;
end
NoThawAnn = annotation('textbox',[.19 .12 .3 .3], 'String','\epsilon=1^{\circ}','EdgeColor','none', 'FontSize', 15, 'Color', 'k');
NoThawAnn = annotation('textbox',[.31 .10 .3 .3], 'String','\epsilon=3^{\circ}','EdgeColor','none', 'FontSize', 15, 'Color', 'm');
NoThawAnn = annotation('textbox',[.43 .2 .3 .3], 'String','\epsilon=5^{\circ}','EdgeColor','none', 'FontSize', 15, 'Color', 'b');


% xs = [21 16 22 15 21]; % dragon
% % xs = [16 14 15 16 16];
% for i=1:1
%     load(sprintf('resultSwarmer-%s-%d.mat','D-N',5), 'pltResults');
%     result3=pltResults(:,1:21);
% 
%     maxY = max(result3(7,:));
% 
%     key = 8;
% % %         subplot(10,1,1) 
%         plotResults('', key, result1(key,:), 'dragon', result2(key,:), 'hat', result3(key,:), 'skateboard');
% % % 
%         txt = 'Number of localizing FLSs';
%         ylabel(txt)
%         xlabel('Rounds (Time)')
% %         axis([0 22 inf inf]);
% % 
% %         annotation('textbox',[.08 .94 .3 .09], 'String',txt,'EdgeColor','none')
%     %     plotResults('', key, result1(key,:), '\epsilon=1^{\circ}', result2(key,:), '\epsilon=3^{\circ}', result3(key,:), '\epsilon=5^{\circ}');
%     
%     yneg = result3(6,:)-result3(1,:);
%     ypos = result3(7,:)-result3(6,:);
%     figure(100);
%     d=errorbar(1:21,result3(6,:),yneg,ypos,'-b*','LineWidth', 1.5);
%     d.Bar.LineStyle = 'dotted';
    %     plotResults('', 1, result3(key,:), '\epsilon=5^{\circ}');
%     
%     
% %     axis([0 22 0 maxY+1])
%     grid on
%     set(gcf, 'Position',  [0 0 560 210])
%     ylim([0 7])
%     xlim padded
%     txt = 'Number of swarms';
%     y=ylabel(txt)
%     xlabel('Rounds (Time)')
%     t = title(' ');
%     tpos = get(t, 'Position');
%     ypos = get(y, 'Position');
%     set(y, 'Position', [0 tpos(2) ypos(3)], 'Rotation', 0, 'HorizontalAlignment', 'left')

% end
% 
% for i=6:10
%     load(sprintf('resultSwarmer-%s-%d.mat','S-N-5',i-5), 'pltResults');
%     result3=pltResults(:,1:xs(i-5));
%     plotResults('', i, result3(3,:), '\epsilon=1^{\circ}')
% end
% plotResults('Number of swarms', 14, result1(14,:), '\epsilon=1^{\circ}', result2(14,:), '\epsilon=3^{\circ}', result3(14,:), '\epsilon=5^{\circ}');
% plotResults('Average Population of Swarms', 16, result1(16,:), '\epsilon=1^{\circ}', result2(16,:), '\epsilon=3^{\circ}', result3(16,:), '\epsilon=5^{\circ}');
% plotResults('Number of Localizing FLSs', 8, result1(8,:), '\epsilon=1^{\circ}', result2(8,:), '\epsilon=3^{\circ}', result3(8,:), '\epsilon=5^{\circ}');
% plotResults('Number of Anchors', 18, result1(18,:), '\epsilon=1^{\circ}', result2(18,:), '\epsilon=3^{\circ}', result3(18,:), '\epsilon=5^{\circ}');
% % plotResults('Number of Shared Anchors', 22, result1(22,:), '\epsilon=1^{\circ}', result2(22,:), '\epsilon=3^{\circ}', result3(22,:), '\epsilon=5^{\circ}');
% plotResults('Average Dead Reckoning Distance Traveled by Localizing FLSs', 23, result1(23,:), '\epsilon=1^{\circ}', result2(23,:), '\epsilon=3^{\circ}', result3(23,:), '\epsilon=5^{\circ}');
% % plotResults('Average Dead Reckoning Distance Traveled by Swarms', 27, result1(27,:), '\epsilon=1^{\circ}', result2(27,:), '\epsilon=3^{\circ}', result3(27,:), '\epsilon=5^{\circ}');


% figure(fig+1000);
% clf

% subplot(2,1,1)   
% plotResults('Hd ', 3, result1(5,:), 'Signal Strenght (SS)', result2(5,:), 'Physical Movement (PM)');
% 
% txt = 'Hausdorff distance';
% y=ylabel(txt)
% ylim tickaligned
% xlim tight
% 
% xlabel('Rounds (Time)')
% t = title(' ');
%     tpos = get(t, 'Position');
%     ypos = get(y, 'Position');
%     set(y, 'Position', [0 tpos(2) ypos(3)], 'Rotation', 0, 'HorizontalAlignment', 'left')
% 
% plotResults('average dead reckoning distance by all flss', 5, result1(3,:), 'Signal Strenght (SS)', result2(3,:), 'Physical Movement (PM)');

% txt = 'Number of Swarms';
% y=ylabel(txt)
% ylim tickaligned
% % xlim tight
% xlabel('Rounds (Time)')
% t = title(' ');
%     tpos = get(t, 'Position');
%     ypos = get(y, 'Position');
%     set(y, 'Position', [0 tpos(2) ypos(3)], 'Rotation', 0, 'HorizontalAlignment', 'left')


% subplot(2,1,2)   
% plotResults('Hd ', 4, result3(5,:), '', result4(5,:), '');

%     plotResults('Number of localizing FLSs', 14, result1(8,:), '\epsilon=5^{\circ}');
% subplot(3,1,1)    
% subplot(3,1,2)
% plotResults('Average error of ptcld ', 19, result1(25,:), '\epsilon=1^{\circ}', result2(25,:), '\epsilon=3^{\circ}', result3(25,:), '\epsilon=5^{\circ}');
% subplot(3,1,3)
% 
% subplot(3,1,1)    
% plotResults('Number of swarms', 1, result1(14,:), 'butterfly', result2(14,:), 'cat', result3(14,:), 'teapot');
% subplot(3,1,2)
% plotResults('Average error of ptcld ', 2, result1(25,:), 'butterfly', result2(25,:), 'cat', result3(25,:), 'teapot');
% subplot(3,1,3)
% plotResults('Hd ', 3, result1(5,:), 'butterfly', result2(5,:), 'cat', result3(5,:), 'teapot');

% subplot(3,1,1)    
% plotResults('Number of swarms', 1, result1(14,:), '');
% ylim tickaligned
% xlim tight
% txt = 'Number of swarms';
% ylabel(txt)
% xlabel('Rounds (Time)')
% % subplot(3,1,2)
% % plotResults('Average error of ptcld ', 2, result1(25,:), '');
% % subplot(3,1,3)
% plotResults('Hd ', 3, result1(5,:), '');
% ylim tickaligned
% xlim tight
% txt = 'Avg distance (cells)';
% ylabel(txt)
% xlabel('Rounds (Time)')

% legend('butterfly', 'cat', 'teapot');
%  plotResults('Average confidence of FLSs ', 20, result1(26,:), '\epsilon=5^{\circ}');

end

