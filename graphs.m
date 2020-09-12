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
T = readtable('data/monte.carlo/dig.6.csv');
histogram2(T.days, T.money);
xlabel('天数');
ylabel('金额');
zlabel('频数');
title('挖六天矿 (开始有人失败)');

figure;
data = [];

function ret = f(x, y)
    ex = x .* 48 + (1.0 - x) .* 144;
    ret = y .* ex + (1.0 - y) .* (ex * 8 + 10) ./ 9;
    disp(ret);
end

function ret = g(x, y)
    ex = x .* 64 + (1.0 - x) .* 144;
    ret = y .* ex + (1.0 - y) .* (ex * 8 + 10) ./ 9;
end
