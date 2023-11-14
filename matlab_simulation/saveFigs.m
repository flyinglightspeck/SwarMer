function saveFigs(label, map)
FolderName = './figs';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = FigHandle.Number;
%   s=sprintf('./figs/comp/fig-%d-%s-%s.jpg', FigName, label, map(FigName));
  s=sprintf('./csv/fig-%d.jpg', FigName);
  saveas(FigHandle, s);
end

end

