classdef FitPlotter < handle
    properties
        inputOutputFig
        inputSubFig
        inputSubFigLeg = string([])
        outputSubFig
        outputSubFigLeg = string([])
        
        loopPlaneFig
        loopSubFig
        loopSubFigLeg = string([]);
        planeSubFig
        
        loopFig
        loopFigLeg = string([]);
        
        surfaceFig;
        
        inputPaperFig;
        outputPaperFig;
        phasePaperFig;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = getOrCreateInputOutputFig(obj)
            if(isempty(obj.inputOutputFig) || ~ishghandle(obj.inputOutputFig))
                obj.inputOutputFig = figure;
                currentPos = get(obj.inputOutputFig, 'Position');
                set(obj.inputOutputFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );
                fig = obj.inputOutputFig;
            else
                fig = figure(obj.inputOutputFig);
            end
        end
        
        function fig = subfigInput(obj, xData, yData, dataLegend, dataColor)
            obj.getOrCreateInputOutputFig();
            
            if(isempty(obj.inputSubFig))
                obj.inputSubFig = subplot(1,2,1); hold on; grid on;
                currentPos = get(obj.inputSubFig, 'Position');
                set(obj.inputSubFig, 'Position', currentPos.*[0.9 1 1 1] + [0 0 0 0] );
            else
                set(obj.inputSubFig, 'nextplot', 'add');
                axes(obj.inputSubFig);
            end
            fig = obj.inputSubFig;
            
            if(nargin>=4 && exist('dataColor', 'var') && ~isempty(dataColor))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.inputSubFigLeg = [obj.inputSubFigLeg, string(dataLegend)];
            leg = legend(obj.inputSubFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        function fig = subfigOutput(obj, xData, yData, dataLegend, dataColor)
            obj.getOrCreateInputOutputFig();
            
            if(isempty(obj.outputSubFig))
                obj.outputSubFig = subplot(1,2,2); hold on; grid on;
                currentPos = get(obj.outputSubFig, 'Position');
                set(obj.outputSubFig, 'Position', currentPos.*[1.0 1 1 1] + [0 0 0 0] );
            else
                set(obj.outputSubFig, 'nextplot', 'add');
                axes(obj.outputSubFig);
            end
            fig = obj.outputSubFig;
            
            if(nargin>=4 && exist('dataColor', 'var') && ~isempty(dataColor))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.outputSubFigLeg = [obj.outputSubFigLeg, string(dataLegend)];
            leg = legend(obj.outputSubFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = getOrCreateLoopPlaneFig(obj)
            if(isempty(obj.loopPlaneFig) || ~ishghandle(obj.loopPlaneFig))
                obj.loopPlaneFig = figure;
                currentPos = get(obj.loopPlaneFig, 'Position');
                set(obj.loopPlaneFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );
                fig = obj.loopPlaneFig;
            else
                fig = figure(obj.loopPlaneFig);
            end
        end
        
        function fig = subfigLoop(obj, xData, yData, dataLegend, dataColor)
            obj.getOrCreateLoopPlaneFig();
            
            if(isempty(obj.loopSubFig))
                obj.loopSubFig = subplot(1,2,1); hold on; grid on;
                currentPos = get(obj.loopSubFig, 'Position');
                set(obj.loopSubFig, 'Position', currentPos.*[0.85 1 1 1] + [0 0 0 0] );
            else
                set(obj.loopSubFig, 'nextplot', 'add');
                axes(obj.loopSubFig);
            end
            fig = obj.loopSubFig;
            
            if(exist('dataColor', 'var'))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.loopSubFigLeg = [obj.loopSubFigLeg, string(dataLegend)];
            leg = legend(obj.loopSubFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        function fig = subfigWeightFunc(obj, weightFunc, inputGrid)  
            obj.getOrCreateLoopPlaneFig();
            
            if(isempty(obj.planeSubFig))
                obj.planeSubFig = subplot(1,2,2); hold on; grid on;
                currentPos = get(obj.planeSubFig, 'Position');
                set(obj.planeSubFig, 'Position', currentPos.*[0.95 1 1 1] + [0 0 0 0] );
                fig = obj.planeSubFig;
            else
                obj.planeSubFig = subplot(1,2,2); hold on; grid on;
                fig = obj.planeSubFig;
            end
            
            % Everything outside Preisach domain to NaN
            gridLength = length(inputGrid);
            for i=1:gridLength
                ii = gridLength-i+1; %index inversion for rows
                for j=1:gridLength
                    if( inputGrid(j)>inputGrid(ii) ) 
                        weightFunc(i,j) = NaN;
                    end
                end
            end
            
            stdDevColorFactor = 2.2;    
            avgColorFactor = 3.5;

            posMu = max(weightFunc,0);
            posNnz = nnz(posMu);
            posAvg = sum(sum(posMu))/posNnz;
            posOnes = spones(posMu);
            posStdDev = sqrt(sum(sum( (posMu - posAvg.*posOnes).^2 ))/posNnz);  
            negMu = min(weightFunc,0);
            negNnz = nnz(negMu);
            negAvg = sum(sum(negMu))/negNnz;
            negOnes = spones(negMu);
            negStdDev = sqrt(sum(sum( (negMu - negAvg.*negOnes).^2 ))/negNnz);

            maxStdDev = nanmax([posStdDev, negStdDev]);
            maxAvg = nanmax([abs(posAvg), abs(negAvg)]);

            [xMesh, yMesh] = meshgrid(inputGrid, fliplr(inputGrid));
            surf(xMesh, yMesh, weightFunc, 'edgecolor', 'none')

            caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     zlim([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     caxis([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
        %     zlim([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);

            colorbar
            colormap jet
            shading interp
            view([0 90])
            
            axis square;
            grid off;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = figLoop(obj, xData, yData, dataLegend, dataColor)            
            if(isempty(obj.loopFig) || ~ishghandle(obj.loopFig))
                obj.loopFig = figure; hold on; grid on;
                fig = obj.loopFig;
            else
                figure(obj.loopFig);
            end
            if(nargin>=4 && exist('dataColor', 'var') && ~isempty(dataColor))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.loopFigLeg = [obj.loopFigLeg, string(dataLegend)];
            leg = legend(obj.loopFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        function fig = figWeightFunc(obj, weightFunc, inputGrid)  
            if(isempty(obj.surfaceFig) || ~ishghandle(obj.surfaceFig))
                obj.surfaceFig = figure; hold on; grid on;
                fig = obj.surfaceFig;
            else
                figure(obj.surfaceFig);
            end
            
            % Everything outside Preisach domain to NaN
            gridLength = length(inputGrid);
            for i=1:gridLength
                ii = gridLength-i+1; %index inversion for rows
                for j=1:gridLength
                    if( inputGrid(j)>inputGrid(ii) ) 
                        weightFunc(i,j) = NaN;
                    end
                end
            end
            
            stdDevColorFactor = 2.2;    
            avgColorFactor = 3.5;

            posMu = max(weightFunc,0);
            posNnz = nnz(posMu);
            posAvg = sum(sum(posMu))/posNnz;
            posOnes = spones(posMu);
            posStdDev = sqrt(sum(sum( (posMu - posAvg.*posOnes).^2 ))/posNnz);  
            negMu = min(weightFunc,0);
            negNnz = nnz(negMu);
            negAvg = sum(sum(negMu))/negNnz;
            negOnes = spones(negMu);
            negStdDev = sqrt(sum(sum( (negMu - negAvg.*negOnes).^2 ))/negNnz);

            maxStdDev = nanmax([posStdDev, negStdDev]);
            maxAvg = nanmax([abs(posAvg), abs(negAvg)]);

            [xMesh, yMesh] = meshgrid(inputGrid, fliplr(inputGrid));
            surf(xMesh, yMesh, weightFunc, 'edgecolor', 'none');
            xlim([inputGrid(1) inputGrid(end)]);
            ylim([inputGrid(1) inputGrid(end)]);

            caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     zlim([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     caxis([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
        %     zlim([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);

            colorbar
            colormap jet
            shading interp
            view([0 90])
            
            axis square;
            grid off;
        end
                
    end
end