classdef DuhemModel < handle
    properties
        f1
        f2
    end
    
    methods (Static=true)
        function curvesCellArray = countourMat2CellArrayLevelCurves(contourMat)
            curveIdx = 0;
            totalElem = 0;
            curvesCellArray = {};
            while totalElem+1<=size(contourMat,2)
                curveIdx = curveIdx + 1;
                pairsCounter = contourMat(2,totalElem + 1);
                curvesCellArray{curveIdx} = contourMat(:,totalElem + 2:totalElem + 1 + pairsCounter)';
                totalElem = totalElem + 1 + pairsCounter;
            end
        end
        
        function [f1,f2,U,Y,uIsoline,yIsoline] = ...
                computef1f2InMesh(duhemModel,uLims,uGridSize,yLims,yGridSize)
            uIsoline = linspace(uLims(1),uLims(2),uGridSize);
            yIsoline = linspace(yLims(1),yLims(2),yGridSize);
            
            f1 = NaN(yGridSize,uGridSize);
            f2 = NaN(yGridSize,uGridSize);
            
            [U,Y] = meshgrid(uIsoline,yIsoline);
            for j=1:uGridSize
                for i=1:yGridSize
                    f1(i,j) = duhemModel.f1(U(i,j),Y(i,j));
                    f2(i,j) = duhemModel.f2(U(i,j),Y(i,j));
                end
            end
        end
        
        function [anHystCurves,avgHystCurve,uIsoline,yIsoline] = ...
                findAnhysteresisCurve(duhemModel,uLims,uGridSize,yLims,yGridSize)
            [f1,f2,U,Y,uIsoline,yIsoline] = ...
                DuhemModel.computef1f2InMesh(duhemModel,uLims,uGridSize,yLims,yGridSize);
            f1(imag(f1)~=0) = NaN;
            f2(imag(f2)~=0) = NaN;
            
            % Anhysteresis curve
            diffF1F2 = f1-f2;
            contourMat = contourc(uIsoline,yIsoline,diffF1F2,[0,0]);
            anHystCurves = DuhemModel.countourMat2CellArrayLevelCurves(contourMat);
            
            % Average curve
            sumF1F2 = f1+f2;
            contourMat = contourc(uIsoline,yIsoline,sumF1F2,[0,0]);
            avgHystCurve = DuhemModel.countourMat2CellArrayLevelCurves(contourMat);
        end
    end
    
    methods
        function model = DuhemModel(f1,f2)
            model.f1 = f1;
            model.f2 = f2;
        end 
        
        function dyq = getdydt(obj,uq,xq,duq)
            if(duq>=0)
                dyq = obj.f1(uq,xq)*duq;
            else
                dyq = obj.f2(uq,xq)*duq;
            end
        end
    end
end