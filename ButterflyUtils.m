classdef ButterflyUtils < handle
    properties
    end
    
    methods(Static=true)
        function [hDistance,index] = horizonalDistance(point,curve)
            [~,index] = min(abs(curve(:,2)-point(2)));
            curvePoint = curve(index,:);
            hDistance = point(1)-curvePoint(1);
        end

        function [vDistance,index] = verticalDistance(point,curve)
            [~,index] = min(abs(curve(:,1)-point(1)));
            curvePoint = curve(index,:);
            vDistance = point(2)-curvePoint(2);
        end
        
        function [distance,index] = closestDistance(point,curve)
            [distance,index] = min( (curve(:,1)-point(1)).^2 + (curve(:,2)-point(2)).^2 );
            distance = sqrt(distance);
        end

        function [signedDistance,index] = signedClosestDistance(point,curve)
            [distance,index] = ButterflyUtils.closestDistance(point,curve);
            slope = ButterflyUtils.slopeAtCurvePoint(index,curve);
            if(isfinite(slope))
                offset = curve(index,2)-slope*curve(index,1);
                signedDistance = sign(slope*point(1)+offset-point(2))*distance;
            else
                signedDistance = sign(point(1)-curve(index,1))*distance;
            end
            signedDistance = signedDistance;
        end
        
        function [slope] = slopeAtCurvePoint(index,curve)
            if(index<size(curve,1))
                y2 = curve(index+1,2);
                y1 = curve(index,2);
                u2 = curve(index+1,1);
                u1 = curve(index,1);
            else
                y2 = curve(index,2);
                y1 = curve(index-1,2);
                u2 = curve(index,1);
                u1 = curve(index-1,1);
            end
            if(u2~=u1)
                slope = (y2-y1)/(u2-u1);
            elseif(y2>y1)
                slope = Inf;
            elseif(y2<y1)
                slope = -Inf;
            else
                slope = NaN;
            end
        end

        function [uLims,yLims,notInfIdxCurve1,notInfIdxCurve2] = getUYLimsFromCurves(curve1,curve2)
            notInfIdxCurve1 = find(isfinite(curve1(:,2)));
            notInfIdxCurve2 = find(isfinite(curve2(:,2)));
            
            minU = max( [min(curve1(notInfIdxCurve1,1)), min(curve2(notInfIdxCurve2,1))] );
            maxU = min( [max(curve1(notInfIdxCurve1,1)), max(curve2(notInfIdxCurve2,1))] );
            minY = max( [min(curve1(notInfIdxCurve1,2)), min(curve2(notInfIdxCurve2,2))] );
            maxY = min( [max(curve1(notInfIdxCurve1,2)), max(curve2(notInfIdxCurve2,2))] );
            uLims = [minU,maxU];
            yLims = [minY,maxY];
        end
        
        function [interpCurve1,interpCurve2,uyIsoline,uLims,yLims] = ...
                interpCurves(curve1, curve2, samples)
            [uLims,yLims,notInfIdxCurve1,notInfIdxCurve2] = ButterflyUtils.getUYLimsFromCurves(curve1,curve2);
            uyIsoline = linspace(uLims(1),uLims(2),samples);
            
            interpCurve1Y = interp1(curve1(notInfIdxCurve1,1),curve1(notInfIdxCurve1,2),uyIsoline,'spline');
            interpCurve1 = [uyIsoline(:),interpCurve1Y(:)];
            
            interpCurve2Y = interp1(curve2(notInfIdxCurve2,1),curve2(notInfIdxCurve2,2),uyIsoline,'spline');
            interpCurve2 = [uyIsoline(:),interpCurve2Y(:)];
        end
        
        
        function [slopeCurve1,slopeCurve2,U,Y,uyIsoline,uLims,yLims] = ...
                computec1c2Slopes(curve1,curve2,samples)
            [interpCurve1,interpCurve2,uyIsoline,uLims,yLims] = ...
                ButterflyUtils.interpCurves(curve1, curve2, samples);
            
            f1 = NaN(samples,samples);
            f2 = NaN(samples,samples);
            slopeCurve1 = NaN(1,samples);
            slopeCurve2 = NaN(1,samples);
            
            [U,Y] = meshgrid( uyIsoline );
            for j=1:samples
                slopeCurve1(j) = ButterflyUtils.slopeAtCurvePoint(j,interpCurve1);
                slopeCurve2(j) = ButterflyUtils.slopeAtCurvePoint(j,interpCurve2);
            end
        end
        
    end
end