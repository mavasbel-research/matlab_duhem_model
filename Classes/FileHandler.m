classdef FileHandler < handle
    properties
        fullFilePath
        filePath
        fileName
        ext

        dataHandler
    end
    
    methods(Static)
        
        %Look for files in a given path and create a list of file handlers
        %with all the matches
        function fileHandlers = lookForFiles(lookupPaths, nameInclude, nameExclude)
            fileHandlers = [];
            for folderCounter=1:length(lookupPaths)
                files = [
                    dir(char(strcat(lookupPaths(folderCounter),'\*.csv')));
                    dir(char(strcat(lookupPaths(folderCounter),'\*.dat')))
                    ];
                for fileCounter=1:length(files)
                    fullFilePath = strcat(files(fileCounter).folder, '\', files(fileCounter).name);
                    [filePath, fileName, ext] = fileparts(fullFilePath);

                    if(nargin>=2 && exist('nameInclude', 'var') && ~isempty(nameInclude))
                        index = regexp(fullFilePath, nameInclude, 'once');
                        if( isempty(index) ) 
                            continue
                        end
                    end

                    if(nargin>=3 && exist('nameExclude', 'var') && ~isempty(nameExclude))
                        index = regexp(fullFilePath, nameExclude, 'once');
                        if( ~isempty(index) ) 
                            continue
                        end
                    end

                    fileHandlers = [fileHandlers; FileHandler(fullFilePath)];
                 end
            end
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        
        function obj = FileHandler(fullFilePath)
            obj.fullFilePath = fullFilePath;
            [obj.filePath, obj.fileName, obj.ext] = fileparts(fullFilePath);
        end
        
        function printInfo(obj)
            disp('--File parameters--')
            disp(strcat('Folder: ', obj.filePath))
            disp(strcat('File: ', obj.fileName))
            disp(strcat('Ext: ', obj.ext))
        end
        
        %Creates a data handler with the found file
        function dataHandler = getDataHandler(obj)
            if(~isempty(obj.dataHandler))
                dataHandler = obj.dataHandler;
                return;
            end
            
            if(obj.ext == '.csv')
                [header, matrix] = obj.readCSV();
            elseif(obj.ext == '.dat')
                [header, matrix] = obj.readDat();
            end

            [origTime, origInputSeq, origOutputSeq] = obj.getInputOutput(header, matrix);
            obj.dataHandler = DataHandler(origInputSeq, origOutputSeq, origTime);
            dataHandler = obj.dataHandler;
        end
        
    end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    methods (Access = private)
        
        function [header, matrix] = readCSV(obj)
            [~, ~, alldata] = xlsread(obj.fullFilePath);

            header = string(strsplit(char(alldata(1,:)),','));

            columns = size(header,2);
            rows = size(alldata,1) - 1;

            matrix = zeros(rows,columns);
            for k=1:rows
                matrix(k,:) = str2double(strsplit(char(alldata(k+1)),','));
            end
        end

        function [header, matrix] = readDat(obj)
            data = importdata(obj.fullFilePath);

            if isfield(data,'colheaders')
                %If data is already formatted
                header = string(data.colheaders);
                matrix = double(data.data(:,:));
            else
                %If data is not formatted determine first row with data
                offset = -1;
                k = 0;
                while(offset == -1)
                    nanvec = isnan(str2double(strsplit(strrep(char(data(k+1)),',','.'),'\t')));
                    if(nanvec(1) == 0)
                        offset = k;
                    else
                        k = k+1;
                    end
                end

                %Create zeros matrix
                rows = size(data,1) - offset;
                columns = size(strsplit(char(data(offset+1)),'\t'),2);
                matrix = zeros(rows,columns);

                %Data header
                header = string(strsplit(strrep(char(data(offset)),',','.'),'\t'));

                %Convert each row to doubles
                for k=1:rows
                    matrix(k,:) = str2double(strsplit(strrep(char(data(k+offset)),',','.'),'\t'));
                end
            end
        end

        function [time, voltage, strain] = getInputOutput(obj, header, matrix)
            time = obj.getColumnMatchingHeader(header, matrix, '.*(Time).*');
            strain = obj.getColumnMatchingHeader(header, matrix, '.*(D1).*');
            vp = obj.getColumnMatchingHeader(header, matrix, '.*(V\+).*');
            vn = obj.getColumnMatchingHeader(header, matrix, '.*(V\-).*');
            voltage = (vp + vn)/2 + (vp - vn)/2;
        end

        function [column] = getColumnMatchingHeader(obj, header, matrix, toMatch)
            column = zeros(size(matrix,1), 1);
            for i=1:length(header)
                index = regexp(header(i), toMatch);
                if(index > 0)
                    column = matrix(:,i);
                    break;
                end
            end
        end
        
    end
    
end