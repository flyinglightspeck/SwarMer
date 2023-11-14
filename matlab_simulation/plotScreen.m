function h = plotScreen(pointCloud, color, f)

fig=figure(f);
clf
% set(fig,'defaultLegendAutoUpdate','off');
if size(pointCloud,1) == 3
    h = scatter3(pointCloud(1,:), pointCloud(2,:), pointCloud(3,:), 60, color, 'filled');
    axis equal
else
    h = scatter(pointCloud(1,:), pointCloud(2,:), 100, color, 'filled');
    axis([0 30 0 30])
    axis equal
    axis square
%     axis equal
end

grid on

end

