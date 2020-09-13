clc; clear; close all;
r = 0 : 0.01 : 1.0;
t = (0 : 0.002 : 0.2)';
t = repmat(t, 1, length(r));

figure;
fplot(@(x) x * 18 + (1.0 - x) * 54);
hold on;
fplot(@(x) x * 24 + (1.0 - x) * 54);
axis([0 1 0 60]);
legend([{'水'}, {'食物'}], 'Location', 'best');
xlabel('晴天概率');
ylabel('期望');

figure;
z = f(r, t);
s = surf(r, t, z);
s.EdgeColor = 'none';
s.FaceAlpha = 0.5;
hold on;
z = g(r, t);
s = surf(r, t, z);
s.EdgeColor = 'none';
s.FaceAlpha = 0.5;

axis([0 1 0 0.2 0 160]);
legend([{'水'}, {'食物'}], 'Location', 'best');
xlabel('晴天概率');
ylabel('沙暴概率');
zlabel('期望');

T = readtable('data/monte.walk.csv');
figure;
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');

figure;
subplot(2, 2, 1);
T = readtable('data/monte.carlo/nope.csv');
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('直接到终点');
subplot(2, 2, 2);
T = readtable('data/monte.carlo/dig.2.csv');
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('挖两天矿');
subplot(2, 2, 3);
T = readtable('data/monte.carlo/dig.4.csv');
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('挖四天矿');
subplot(2, 2, 4);
T = readtable('data/monte.carlo/dig.5.csv');
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('挖五天矿 (开始有人失败)');

T = readtable('data/monte.carlo/dig.ult.csv');
figure;
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('挖 4 天矿 - 回村 - 挖 4 天矿 - 回村 - 挖 3 天矿 - 到终点');
disp('mean food: ' + string(mean(T.food)) + ', mean water: ' + string(mean(T.water)));

figure;
data = [30 34; 24 26; 6 8; 0 0];
subplot(1, 2, 1);
bar3(data);
legend('水', '食物');
xlabel('天数');
zlabel('数量（箱）');
title('玩家一');
subplot(1, 2, 2);
data = [33 38; 30 34; 12 16; 6 8; 0 0];
bar3(data);
legend('水', '食物');
xlabel('天数');
zlabel('数量（箱）');
title('玩家二');

figure;
subplot(1, 2, 1);
T = readtable('data/monte.carlo/dig.initial.csv');
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('直接走到终点');
subplot(1, 2, 2);
T = readtable('data/monte.carlo/dig.consect.csv');
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('挖矿');

figure;
subplot(1, 4, 1);
T = table2array(readtable('data/monte.carlo/dig.ev.csv'));
histogram(T);
xlabel('最终合计金额');
ylabel('频数');
title('三玩家轮流挖矿');
ex = mean(T);
legend('最大值: ' + string(max(T)) + ', 期望: ' + ex);
subplot(1, 4, 2);
T = table2array(readtable('data/monte.carlo/nope.ev.csv'));
histogram(T);
xlabel('最终合计金额');
ylabel('频数');
title('三玩家直接前往终点');
ex = mean(T);
legend('最大值: ' + string(max(T)) + ', 期望: ' + ex);
subplot(1, 4, 3);
T = table2array(readtable('data/monte.carlo/dig.one.csv'));
histogram(T);
xlabel('最终合计金额');
ylabel('频数');
title('一名玩家挖矿，其余前往终点');
ex = mean(T);
legend('最大值: ' + string(max(T)) + ', 期望: ' + ex);
subplot(1, 4, 4);
T = table2array(readtable('data/monte.carlo/dig.two.csv'));
histogram(T);
xlabel('最终合计金额');
ylabel('频数');
title('一名玩家前往终点，其余挖矿');
ex = mean(T);
legend('最大值: ' + string(max(T)) + ', 期望: ' + ex);

function ret = f(x, y)
    ex = x .* 48 + (1.0 - x) .* 144;
    ret = y .* ex + (1.0 - y) .* (ex * 8 + 10) ./ 9;
    disp(ret);
end

function ret = g(x, y)
    ex = x .* 64 + (1.0 - x) .* 144;
    ret = y .* ex + (1.0 - y) .* (ex * 8 + 10) ./ 9;
end
