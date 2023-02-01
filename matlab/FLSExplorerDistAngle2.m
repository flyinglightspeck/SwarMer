classdef FLSExplorerDistAngle2 < FLSExplorer
    methods
        function obj = FLSExplorerDistAngle2(freezePolicy)
            obj.freezePolicy = freezePolicy;
        end

        function success = init(obj, fls)
            obj.wayPoints = [];
            obj.neighbor = 0;
            obj.scores = [];

            obj.i = 0;
            obj.bestIndex = 0;

            N = fls.elNeighbors(1);

            [phi, theta] = getVectorAngleX(N.el, fls.el);

            d = fls.distModel.getDistance(fls, N);
            D = fls.gtl - N.gtl;

            if fls.D == 3
                dv = [d * sin(theta) * cos(phi); d * sin(theta) * sin(phi); d * cos(theta)];
            else
                dv = [d * cos(phi); d * sin(phi)];
            end

            V = D - dv;
            P = fls.el + V;

%             scatter(N.el(1), N.el(2), 'filled', 'blue')
%             scatter(fls.el(1), fls.el(2), 'filled', 'green')
%             scatter(P(1), P(2), 'green')

            obj.wayPoints(:,1) = P;
            obj.neighbor = N;
            
            D1 = [N.el] - fls.el;

            dx = sign(D1(1));
            if dx == 0
                dx = 1;
            end
            if fls.D == 3
                D1 = D1 - [dx*0.1; 0; 0];
            else
                D1 = D1 - [dx*0.1; 0];
            end

            obj.d0 = V;
            obj.d1 = D1;
            obj.d2 = P - fls.el - D1;
            
            success = 1;
        end
    end
end

