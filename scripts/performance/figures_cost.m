% Grafica
clear all

%cost_2 = [2123442;	47841;	133407;	30807;	135717;	159871];
%cost_5 = [2200272; 47841; 128274.6;30807;284323;353643];
%cost_10 = [2328310;47841;126565.8;30807;532001;676651];

%cost_2 = [2211053; 72204;	133469;	30807;	135695;	162055];
%cost_5 = [2287883; 72204; 128339;30807;284301;355847];
%cost_10 = [2415921;72204;126628;30807;531967;678835];

cost_2 = [2169252; 70428;134426;30814;135717;	162055];
cost_5 = [2246082; 70428;128997;30814;284323;355847];
cost_10 = [2374120;70428;127009;30814;531989;678835];


cost = [cost_2 cost_5 cost_10];

str = {'deploy'; 'initialize'; 'input'; 'initEval.'; 'output'; 'solveStack.'};
gcf=figure(100);

bar (cost);

box on
grid on

ylim([0 2400000]);
yticks(0:200000:2400000);
YTickLabel = get(gca,'YTick');
set(gca,'YTickLabel',num2str(YTickLabel'))
set(gca, 'XTickLabel',str, 'XTick',1:numel(str));

ylabel('Cost (gas units)','Interpreter','latex')
legend ({'2 operators'; '5 operators'; '10 operators'}, 'Interpreter','latex');
set(gca,'TickLabelInterpreter','latex');
set(gcf, 'PaperPositionMode', 'auto');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [2.5 2.5 15 10]); % last 2 are width/height.
print(gcf,'-depsc2', '-painters', '-loose', 'cost-gas.eps');
eps2pdf('cost-gas.eps');
delete cost-gas.eps