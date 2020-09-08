function graphs()
    close all;
    line_plot();
    stock_plot();
    scatter_plot();
    datetime_plot();
    implicit_function_plot();
    function_plot();
    line_plot_3d();
    function_plot_3d();
    logspace_plot();
    semilogy_plot();
    vertical_bar_plot();
    vertical_stack_bar_plot();
    horizontal_bar_plot();
    datetime_bar_plot();
    bar_plot_3d();
    histogram_plot();
    bivariate_histogram_plot();
    categorical_histogram_plot();
    heatmap_plot();
    pie_plot();
    pie_plot_explode();
    pie_plot_3d();
    area_plot();
    contour_plot();
    function_contour_plot();
    polar_plot();
    easy_polar_plot();
    rose_plot();
    polar_histogram_plot();
end

function line_plot()
    x = 0.0 : 0.1 : 2.0 * pi;
    y1 = cos(x);
    y2 = sin(x);
    
    figure;
    plot(x, y1, 'b', x, y2, 'r-.', 'LineWidth', 2);
    grid on;
    axis([0 2.0 * pi -1.5 1.5]);
    title('Trigonometric Functions');
    xlabel('angle');
    ylabel('sin(x) & cos(x)');
end

function stock_plot()
    t1 = datetime(2018, 1, 1, 8, 0, 0);
    t2 = datetime(2020, 1, 1, 8, 0, 0);
    t = t1 : t2;
    rd = rand(length(t), 2) .* 100.0;
    series = [{'随便'}, {'不知道'}];
    
    figure;
    plot(t, rd);
    datetick('x');
    xlabel('Date');
    ylabel('Index Value');
    title('Relative Daily Index Closings');
    legend(series, 'Location', 'northwest');
end

function scatter_plot()
    x = 0.0 : 0.1 : 2.0 * pi;
    y1 = sin(x) + rand() * 2.0;
    y2 = cos(x) + rand() * 2.0;
    figure;
    plot(x, y1, 'bo');
    hold on;
    plot(x, y2, 'r+');
    axis([0 2.0 * pi -5.0 5.0]);
    title('RV plot');
    xlabel('It doesn''t matter');
    ylabel('I dunno');
    series = [{'dunno'}, {'doesn''t matter'}];
    legend(series, 'Location', 'northeast');
end

function datetime_plot()
    t1 = datetime(2020, 7, 2, 8, 0, 0);
    t2 = datetime(2020, 9, 5, 8, 0, 0);
    t = t1 : t2;
    rd1 = sin(datenum(t)) + rand() * 2.0;
    figure;
    plot(t, rd1);
    limits = [t1, t2];
    xlim(limits);
    ax = gca;
    ax.XAxis.TickLabelFormat = 'MMMM dd';
    ax.XAxis.TickLabelRotation = 40;
    xlabel('date');
    ylabel('dunno');
    title('Random Heat Map');
end

function implicit_function_plot()
    figure;
    fimplicit(@(x, y) (x .^ 2.0 + y .^ 2.0) .^ 2.0 - x .^ 2.0 + y .^ 2.0, [-1.1 1.1 -1.1 1.1]);
    colormap([0 0 1]);
    title('Lemniscate Function');
end

function function_plot()
    figure;
    fplot(@(x) x .^ 2 .* (3.0 - 2.0 .* x), [-1.0 1.0], 'r', 'LineWidth', 2);
    xlabel('x');
    ylabel('y');
    title('Smoothstep Function');
end

function line_plot_3d()
    x = 0.0 : 0.1 : 2.0 * pi;
    y = [
        x;
        1.5 * x;
        2.0 * x;
        2.5 * x;
        3.0 * x;
        3.5 * x;
        4.0 * x;
    ];
    z = sin(x) + cos(y);
    figure;
    plot3(x, y, z);
    box on;
    axis([0.0 2.0 * pi 0.0 2.0 * pi -10.0 10.0]);
end

function function_plot_3d()
    figure;
    fplot3(@cos, @sin, @(t) sin(5.0 * t), [-pi, pi]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title('Rotation thing yay');
end

function logspace_plot()
    zeta = [0.01 0.02 0.05 0.1 0.2 0.5 1.0];
    colors = ['r' 'g' 'b' 'c' 'm' 'y' 'k'];
    w = logspace(-1, 1, 1000);
    figure;    
    for i = 1 : 7
        a = w .^ 2.0 - 1.0;
        b = 2.0 * w * zeta(i);
        gain = sqrt(1.0 ./ (a .^ 2.0 + b .^ 2.0));
        loglog(w, gain, 'Color', colors(i), 'LineWidth', 2);
        hold on;
    end
    axis([0.1 10 0.01 100]);
    title('Fancy graphs');
end

function semilogy_plot()
    eb = 0 : 5;
    ser = [0.1447 0.1112 0.0722 0.0438 0.0243 0.0122];
    ber = [0.0753 0.0574 0.0370 0.0222 0.0122 0.0061];
    figure;
    semilogy(eb, ser, 'bo-');
    hold on;
    semilogy(eb, ber, 'r^-');
    title('Performance of Baseband QPSK');
    xlabel('EbNo (db)');
    ylabel('SER and BER');
    legend('SER', 'BER', 'Location', 'best');
end

function vertical_bar_plot()
    a = randi(10, 1, 10);
    b = randi(10, 1, 10);
    c = randi(10, 1, 10);
    figure;
    bar(1 : 10, [a' b' c'], 1);
    axis([0 11 0 10]);
    legend('Unimportant', 'Nope', 'Whatever', 'Location', 'best');
end

function vertical_stack_bar_plot()
    a = randi(10, 1, 10)';
    b = randi(10, 1, 10)';
    c = randi(10, 1, 10)';
    figure;
    bar(1 : 10, [a b c], 0.5, 'stacked');
    axis([0 11 0 40]);
    legend('Unimportant', 'Nope', 'Whatever', 'Location', 'best');
end

function horizontal_bar_plot()
    a = randi(10, 10, 1);
    figure;
    barh(1 : 10, a, 0.9);
    axis([0 10 0 11]);
end

% So it looks like datetick is not needed here?
function datetime_bar_plot()
    t1 = datetime(2020, 8, 1);
    t2 = datetime(2020, 9, 5);
    t = t1 : t2;
    a = randi(100, length(t), 1);
    bar(t, a);
    xlabel('Date');
    ylabel('Dunno');
end

function bar_plot_3d()
    z = randi(10, 10, 3);
    figure;
    bar3(z);
    axis([0, 4, 0, 11, 0, 11]);
end

function histogram_plot()
    rv = floor((rand(10, 100, 3) .^ 2.0) .* 10.0);
    figure;
    h1 = histogram(rv(:, 1));
    hold on;
    histogram(rv(:, 2), h1.BinEdges);
    histogram(rv(:, 3), h1.BinEdges);
    hold off;
    legend('A', 'B', 'C');
end

function bivariate_histogram_plot()
    x = randn(10000, 1);
    y = randn(10000, 1);
    figure;
    histogram2(x, y);
end

function categorical_histogram_plot()
    rv = randi(4, 100, 1);
    rv = categorical(rv, [1 2 3 4], {'Poor', 'Fair', 'Good', 'Excellent'});
    figure;
    histogram(rv);
end

function heatmap_plot()
    names = {'hello'; 'goodbye'; 'whatever'; 'random'};
    age = randi(10, length(names), 1);
    t = table(names, age);
    figure;
    heatmap(t, 'names', 'age');
end

function pie_plot()
    rv = randi(100, 5, 1);
    figure;
    pie(rv, {'First'; 'Second'; 'Third'; 'Forth'; 'Fifth'});
end

function pie_plot_explode()
    rv = randi(100, 5, 1);
    exp = randi(1, 5, 1);
    figure;
    pie(rv, exp, {'First'; 'Second'; 'Third'; 'Forth'; 'Fifth'});
end

function pie_plot_3d()
    rv = randi(100, 5, 1);
    exp = randi(1, 5, 1);
    figure;
    pie3(rv, exp, {'First'; 'Second'; 'Third'; 'Forth'; 'Fifth'});
end

function area_plot()
    x = 0.0 : 0.5 : 2.0 * pi;
    y = randn(length(x), 4);
    base_value = -1;
    figure;
    colormap winter;
    area(y, base_value);
end

function contour_plot()
    lon = 0 : 0.1 : 3.0;
    lat = 0 : 0.1 : 3.0;
    elev = rand(length(lon), length(lat)) .* 34.0;
    figure;
    contour(lon, lat, elev);
end

function function_contour_plot()
    figure;
    fcontour(@(x, y) sin(3.0 * x) .* cos(x + y), [0 3 0 3], 'Fill', 'on', 'LineColor', 'k');
end

function polar_plot()
    t = 0 : 0.01 : 2.0 * pi;
    r = abs(sin(2.0 * t) .* cos(2.0 * t));
    figure;
    polarplot(t, r);
    title('Polar plot');
end

function easy_polar_plot()
    figure;
    ezpolar('1.0 + cos(t) * sin(t) ^ 2.0');
end

function rose_plot()
    rv = randn(100, 1);
    figure;
    rose(rv, 10);
end

function polar_histogram_plot()
    rv = randn(100, 1);
    figure;
    polarhistogram(rv, 10);
end
