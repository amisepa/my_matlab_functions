% Plots 2 times series, their 95% CI and significance bars at the bottom
% from h vector (FDR-corrected p-values). If method is not precised,
% 10% trimmed mean is used. 
% 
% Usage:
%   - plotDiff(xAxis, data1, data2, method, h, data1Name, data2Name);
%   - plotDiff(freqs, power1, power2, 'mean', [], 'condition 1','condition 2');
% 
% Data must be 2-D. Values in column 1 and subjects in column 2 (e.g.,freqs x subjects)
% 
% Cedric Cannard, 2021

function plotDiff(xAxis, data1, data2, method, h, data1Name, data2Name)

if size(xAxis,1) > size(xAxis,2)
    xAxis = xAxis';
end

if exist('h', 'var') && ~isempty(h)
    sigBars = true;
else
    sigBars = false;
end

color1 = [0, 0.4470, 0.7410];
color2 = [0.8500, 0.3250, 0.0980];

n = size(data1,2);
if strcmpi(method, 'mean')
    data1_mean = mean(data1,2,'omitnan');
else
    data1_mean = trimmean(data1,10,2);
end
data1_se = std(data1,[],2,'omitnan') ./ sqrt(n)';     % Standard error
% data1_se = std(data1,[],2,'omitnan');                   % standard deviation
data1_t = tinv([.025 .975],n-1);  % t-score
data1_CI = data1_mean' + (-data1_t.*data1_se)';

n = size(data2,2);
if strcmpi(method, 'mean')
    data2_mean = mean(data2,2,'omitnan');
else
    data2_mean = trimmean(data2,20,2);
end
data2_se = std(data2,[],2,'omitnan') ./ sqrt(n)';     % standard error
% data2_se = std(data2,[],2,'omitnan');                   % standard deviation
data2_t = tinv([.025 .975],n-1);  %t-score
data2_CI = data2_mean' + (-data2_t.*data2_se)';

% figure; set(gcf,'Color','w');

% Data1 (mean + 95% CI)
p1 = plot(xAxis,data1_mean,'LineWidth',2,'Color', color1);
patch([xAxis fliplr(xAxis)], [data1_CI(1,:) fliplr(data1_CI(2,:))], ...
    color1,'FaceAlpha',.4,'EdgeColor',color1,'EdgeAlpha',.7);
set(gca,'FontSize',12,'layer','top'); 
hold on;

% Data2 (mean + 95% CI)
p2 = plot(xAxis,data2_mean,'LineWidth',2,'Color', color2);
patch([xAxis fliplr(xAxis)], [data2_CI(1,:) fliplr(data2_CI(2,:))], ...
    color2,'FaceAlpha',.4,'EdgeColor',color2,'EdgeAlpha',.7);
set(gca,'FontSize',12,'layer','top'); 
% hold off;

% Plot significance bar at the bottom
if sigBars
    plotSigBar(h, xAxis);
end

% legend([p1, p2], {data1Name,data2Name}, 'Orientation','vertical'); 

% grid on; 
axis tight;  
box on
