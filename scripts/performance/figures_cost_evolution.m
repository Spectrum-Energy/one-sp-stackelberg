% Script to generate figures of estimated average cost of the main functions (measured in USD) over a 12-month period
% (July 2022 to July 2023) considering the average gas price.

% Import csv file manually in Matlab (double click on the Cost-1spMop-USDCost-C=5.csv file and import)
data1 = Cost1spMopUSDCostC5;
blockchains = ["ethereum" "polygon"];

for i=1:1:length(blockchains)
    gcf=figure(100 * i);
    blockchain = blockchains(i);
    hold on;
    if strcmp(blockchain, "ethereum")
        plot(data1.DateUTC, data1.initialize, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.input, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.initEvaluation, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.outputoffchain, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.outputonchain, 'LineWidth',1.2)
    else
        plot(data1.DateUTC, data1.initialize1, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.input1, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.initEvaluation1, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.outputoffchain1, 'LineWidth',1.2)
        plot(data1.DateUTC, data1.outputonchain1, 'LineWidth',1.2)
    end
    
    hold off;
    YTickLabel = get(gca,'YTick');
    set(gca,'YTickLabel',num2str(YTickLabel'))
    set(gca,'TickLabelInterpreter','latex');
    ylabel('Cost (USD)','Interpreter','latex');
    
    if strcmp(blockchain, "ethereum")
        legend ({'initialize'; 'input'; 'initEvaluation'; 'output'; 'solveStackelberg'}, 'Interpreter','latex', 'Location', 'northwest');
    else
        legend ({'initialize'; 'input'; 'initEvaluation'; 'output'; 'solveStackelberg'}, 'Interpreter','latex', 'Location', 'northeast');
    end
    
    box on;
    grid on;
    filename = strcat('cost-', blockchain, '.eps');
    set(gcf, 'PaperPositionMode', 'auto');
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [2.5 2.5 16 7]); % last 2 are width/height.
    print(gcf,'-depsc2', '-painters', '-loose', filename);
    eps2pdf(convertStringsToChars(filename));
end

delete cost-ethereum.eps;
delete cost-polygon.eps;