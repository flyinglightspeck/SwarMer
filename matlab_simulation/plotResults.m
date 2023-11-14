function plotResults(T, fig, varargin)
figure(fig)
clf

A = varargin{1};

x=1:size(A,2);

extraInputs = {'interpreter','latex','fontsize',18};


% t=title(T);
%xlabel('Point Cloud ID',extraInputs{:})
%ylabel('Execution Time (Seconds)',extraInputs{:})
% xlabel('',extraInputs{:})
% ylabel('',extraInputs{:})

lgd = legend;
lgd.FontSize = 14;

%{
y = ylabel('Total Flight Distance (Cells)');
vf = 1.125; % vertical factor. Adjust manually
dy = .55; % horizontal offset. Adjust manually
tpos = get(t, 'Position');
theight = tpos(2);
ypos = get(t, 'Position');
set(y, 'Position', [ypos(1)+dy tpos(2)*1.02 ypos(3)], 'Rotation', 0)
%}

extraInputs = {'Helvetica','latex','fontsize',18};

grid on;

%{
plot(x,yICF,'-bo','LineWidth', 2.5,'DisplayName','ICF')
hold on 
plot(x,yICL,'--mx','LineWidth', 2.5,'DisplayName','ICL')
hold on 
%plot(x,simple,'--cx') 
%}

styles = {'-k*', '-mx', '-b+', '-go'};
% styles = {'-c*', '-go'};


for i = 1:floor((nargin-2)/2)
    h=plot(1:size(varargin{2*i-1},2),varargin{2*i - 1}, styles{i}, 'LineWidth', 1.5,'DisplayName',varargin{2*i});
    ax = ancestor(h, 'axes');
    ax.YAxis.Exponent = 0;
    grid on
    hold on 
end

% hold off
% axes('Xlim', [1,28], 'XTick', 1:2:36);
set(gcf, 'Position',  [0 0 560 210])
% legend(varargin{2}, varargin{4}, varargin{6});
% legend(varargin{2}, varargin{4});
end