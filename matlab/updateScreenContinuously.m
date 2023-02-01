function frames = updateScreenContinuously(h, pointCloud, gifName, sV, dv)

k=10;
frames = [];

startX = h.XData;
endX = pointCloud(1,:);

startY = h.YData;
endY = pointCloud(2,:);

if size(pointCloud,1) == 3
    startZ = h.ZData;
    endZ = pointCloud(3,:);
    deltaZ = (endZ-startZ)/k;
end

deltaX = (endX-startX)/k;
deltaY = (endY-startY)/k;
dv = dv/k;

for i=1:k

if size(pointCloud,1) == 3
    set(h, 'XData', startX+i*deltaX, 'YData', startY+i*deltaY, 'ZData', startZ+i*deltaZ)
else
    set(h, 'XData', startX+i*deltaX, 'YData', startY+i*deltaY)
end
if sV~=0
view(sV+i*dv);
end
% frames = [frames getframe(gcf)];
drawnow

if i~=k
frames = [frames getframe(gcf)];
end
end


% grid on
% axis([0 30 0 30])
% axis square
% axis equal

end

