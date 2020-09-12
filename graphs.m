r = 0 : 0.01 : 1.0;

figure;
fplot(@(x) x * 18 + (1.0 - x) * 54);
hold on;
fplot(@(x) x * 24 + (1.0 - x) * 54);
axis([0 1 0 60]);
legend([{'水'}, {'食物'}], 'Location', 'best');
xlabel('晴天概率');
ylabel('期望');
