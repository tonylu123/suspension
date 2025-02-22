function z = ParamSweep(carCells,params)

%Creates graphs showing the change in points for a given change in
%carConfig parameter. Plots points for each event and total points and
%creates line of best fit. Writes data to excel spreedsheet with the
%filename listed below. Written by Nick Injo; message for any ques!

%How to use:
%In carConfig.m, change desired car parameter to array of multiple values
%Run SteadyStateLapsim.m
%Copy carCell cell array to different name in workspace
%Re-run lapsim for any additional parameter changes
%Create cell array with all carCell entries
%Add switch statements to match location of your desired parameter

%Inputs: 
%carCells-cell array containing multiple "carCell" outputs from lapsim
%params-cell array containing the string names of the tested variables
%used for case statements and graph titles
  

    z = figure;
    filename = 'Weight_Sweep.xlsx';

    %checks how many params were tested
    for e = 1:length(carCells)
        
        [r,~] = size(carCells{e}); %number of data points
        test_var1 = zeros(1,r); %preallocate cda/cla list
        point_cell = cell(1,5); %4 events and tot points

        %check which param is changing and get vals
        for i = 1:r
            point_list = struct2array(carCells{e}{i,1}.comp.points);

            switch params{e}    
            case "cda"
                test_var1(i) = carCells{e}{i,1}.aero.cda;
            case "cla"
                test_var1(i) = carCells{e}{i,1}.aero.cla;
            case "weight"
                test_var1(i) = carCells{e}{i,1}.M*2.20462;
            end

            %get pts from carCell events
            for x = 1:length(point_list)    
                point_cell{x} = [point_cell{x},point_list(x)];
            end

        end   

        %plotting for the 5 events
        events = {'Skidpad' 'Accel' 'AutoX' 'Endurance' 'Total'};
        
        for a = 1:5     

            if a~=5
               subplot(3,2,a);
            else
               subplot(3,2,a:6); 
            end
            
            x1 = test_var1;
            y1 = point_cell{a};
            scatter(x1,y1,'filled','DisplayName',params{e});
            
            hold on
            
            % Fit model to data from curvefit app
            [xData, yData] = prepareCurveData(x1,y1);%(x1(1:r-1),y1(1:r-1));
            ft = fittype( 'poly1' );
            excludedPoints = xData <= 0;
            opts = fitoptions( 'Method', 'LinearLeastSquares' );
            opts.Exclude = excludedPoints;
            [fitresult, gof] = fit( xData, yData, ft, opts );
            x = x1(1):1:x1(r); %0:.1:5
            format short g
            equa = round(coeffvalues(fitresult),2);
            gof.rsquare(isnan(gof.rsquare)) = 0;
            plot(x,fitresult(x),'k','DisplayName',...
                ['y=',num2str(equa(1)),'x+',num2str(equa(2)),...
                ', r^2: ',num2str(fix(gof.rsquare*10^3)/10^3)]);
            
            %creating words
            title([events{a} ' Points'])
            xlabel( [params{e} ' (lb)'])
            ylabel('Points')
            legend('FontSize',6,'Location','NorthEast')
            
            hold on

        end
        
        %write to filename
        % T = table(params,events,test_var1,point_cell);
        % writetable(T,filename,'Sheet',2,'WriteVariableNames',false);
       
    end
     
end