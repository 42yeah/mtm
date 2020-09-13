classdef main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        UIAxes                  matlab.ui.control.UIAxes
        Label                   matlab.ui.control.Label
        EditField               matlab.ui.control.EditField
        Button                  matlab.ui.control.Button
        Button_2                matlab.ui.control.Button
        Label_2                 matlab.ui.control.Label
        Label_3                 matlab.ui.control.Label
        Label_4                 matlab.ui.control.Label
        EditField_2             matlab.ui.control.EditField
        Label_5                 matlab.ui.control.Label
        EditField_3             matlab.ui.control.EditField
        Button_3                matlab.ui.control.Button
        Button_4                matlab.ui.control.Button
        Label_6                 matlab.ui.control.Label
        Button_5                matlab.ui.control.Button
        Label_9                 matlab.ui.control.Label
        DropDown                matlab.ui.control.DropDown
        Button_6                matlab.ui.control.Button
        DijkstraEditFieldLabel  matlab.ui.control.Label
        DijkstraEditField       matlab.ui.control.EditField
        Button_7                matlab.ui.control.Button
        Label_10                matlab.ui.control.Label
        Label_11                matlab.ui.control.Label
        EditField_4             matlab.ui.control.EditField
        Button_8                matlab.ui.control.Button
        Label_12                matlab.ui.control.Label
        EditField_5             matlab.ui.control.EditField
        Button_9                matlab.ui.control.Button
        Button_10               matlab.ui.control.Button
        Label_13                matlab.ui.control.Label
        EditField_6             matlab.ui.control.EditField
        Label_14                matlab.ui.control.Label
        EditField_7             matlab.ui.control.EditField
        Button_11               matlab.ui.control.Button
        Label_15                matlab.ui.control.Label
        EditField_8             matlab.ui.control.EditField
        Label_16                matlab.ui.control.Label
        Button_12               matlab.ui.control.Button
        Button_13               matlab.ui.control.Button
    end

    
    properties (Access = private)
        m = []; % map
        reps = []; % numeric representation of node
        labels = []; % textual representation of node
        food = 0;
        water = 0;
        money = 0;
        weathers = [];
        day = 1;
        parameters = table();
        node = 1;
        validDests = [];
        villages = [];
        mines = [];
        terminal = -1;
        mineCooldown = 0;
        dijkstra = [];
        path = zeros(0, 0);
        path2 = zeros(0, 0);
        t = table();
    end
    
    methods (Access = private)
        function str = getWeather(app)
            switch (app.weathers(app.day))
                case 1
                    str = '晴天';
                case 2
                    str = '高温';
                case 3
                    str = '沙尘暴';
                otherwise
                    str = '不知道';
            end
        end

        % Available parameters:
        % food, water, money, water_wgt, food_wgt, encumbrance, income,
        % water_con, food_con, water_price, food_price
        function d = fetch(app, key)
            d = app.parameters(1, key).(1);
            switch (key)
                % Whatever works
                case 'water_con'
                    a = strsplit(d{1}, ',');
                    b = zeros(1, length(a));
                    for i = 1 : length(a)
                        b(i) = str2num(string(a(i)));
                    end
                    d = b;
                case 'food_con'
                    a = strsplit(d{1}, ',');
                    b = zeros(1, length(a));
                    for i = 1 : length(a)
                        b(i) = str2num(string(a(i)));
                    end
                    d = b;
            end
        end
        
        function render(app)
            g = graph(app.m, 'upper', 'omitselfloops');
            
            edgeLabels = strings(height(g.Edges), 1);
%             foodPrice = app.fetch('food_con');
%             waterPrice = app.fetch('water_con');
%             wotd = app.weathers(app.day);
%             e = [-foodPrice(wotd) -waterPrice(wotd) 0];
%             for i = 1 : height(g.Edges)
%                 ed = g.Edges.EndNodes(i, :);
%                 disp(ed);
%                 if ed(1) ~= ed(2)
%                     d = e .* 2;
%                 else
%                     d = e;
%                 end
%                 edgeLabels(i) = '[' + string(d(1)) + ',' + string(d(2)) + ',' + string(d(3)) + ']';
%             end
            
            title(app.UIAxes, '穿越沙漠');
            h = plot(app.UIAxes, g, 'NodeLabel', app.labels, 'EdgeLabel', edgeLabels);
%             labeledge(h, g.Edges, edgeLabels);
            highlight(h, [app.node], 'NodeColor', 'g');
            highlight(h, app.villages, 'NodeColor', 'm', 'MarkerSize', 7);
            highlight(h, app.mines, 'NodeColor', 'y', 'MarkerSize', 7);
            highlight(h, [app.terminal], 'MarkerSize', 10, 'NodeColor', 'r');
            highlight(h, app.path, 'EdgeColor', 'r', 'LineWidth', 3);
            highlight(h, app.path2, 'EdgeColor', 'r', 'LineWidth', 3);

            totalWgt = app.food * app.fetch('food_wgt') + app.water * app.fetch('water_wgt');
            death = '';
            if app.food < 0 || app.water < 0
                death = '讲道理，你已经死了。';
            end
            if app.reps(app.node) == 3
                app.Label_2.Text = death + string('你赢了！折算后，你最终有 ' + string(app.money) + ' 元。');
            else
                app.Label_2.Text = strcat(death, '你有 ', num2str(app.food), ' 食物, ', num2str(app.water), ' 水, ', num2str(app.money), ' 块钱, 重量 ', num2str(totalWgt) , '/', num2str(app.fetch('encumbrance')));
            end
            app.Label_3.Text = strcat('今天是 ', app.getWeather(), ' 今天是第 ', num2str(app.day - 1), ' 天, 你位于节点 ', num2str(app.node));
            
            if app.day > 1 && app.reps(app.node) ~= 1
                app.Button_3.Enable = false;
            else
                app.Button_3.Enable = true;
            end
            
            app.validDests = [];
            for i = 1 : length(app.m)
                if app.m(app.node, i) == 1
                    app.validDests = [app.validDests i];
                end
            end
            app.DropDown.Items = string(app.validDests);
            app.DropDown.ItemsData = app.validDests;
            
            if app.reps(app.node) == 2 && app.mineCooldown <= 0
                app.Button_6.Enable = true;
            else
                app.Button_6.Enable = false;
            end

            if app.weathers(app.day) == 3
                app.Button_5.Enable = false;
            else
                app.Button_5.Enable = true;
            end
        end
        
        function ret = purchase(app, foodCount, waterCount)
            if app.day > 1 && app.reps(app.node) ~= 1
                disp('不是第 1 天，不在村庄上');
                ret = false;
                return;
            end
            multiplier = 1;
            if app.reps(app.node) == 1
                multiplier = 2;
            end
            sum = (waterCount * app.fetch('water_price') + foodCount * app.fetch('food_price')) * multiplier;
            if sum >= app.money
                disp('钱不够');
                ret = false;
                return;
            end
            if (app.food + foodCount) * app.fetch('food_wgt') + (app.water + waterCount) * app.fetch('water_wgt') > app.fetch('encumbrance') 
                disp('装不下');
                ret = false;
                return;
            end
            app.money = app.money - sum;
            app.food = app.food + foodCount;
            app.water = app.water + waterCount;
            ret = true;
        end
    
        % Pass the day.
        function pass(app)
            foodCost = app.fetch('food_con');
            waterCost = app.fetch('water_con');
            app.food = app.food - foodCost(app.weathers(app.day));
            app.water = app.water - waterCost(app.weathers(app.day));
            app.day = app.day + 1;
            if app.reps(app.node) == 2 
                app.mineCooldown = app.mineCooldown - 1;
            else
                app.mineCooldown = 0;
            end
        end
        
        % Travel to adjancent area.
        function travel(app, dest)
            if app.weathers(app.day) == 3
                disp('今天是沙尘暴');
                return;
            end
            if any(app.validDests(:) == dest)
                app.mineCooldown = 0;
                app.node = dest;
                foodCost = app.fetch('food_con');
                waterCost = app.fetch('water_con');
                app.food = app.food - foodCost(app.weathers(app.day)) * 2;
                app.water = app.water - waterCost(app.weathers(app.day)) * 2;
                app.day = app.day + 1;
                if app.reps(dest) == 3
                    app.completed();
                end
            else
                disp('没法去那');
            end
        end
        
        function ret = mine(app)
            if ~(app.reps(app.node) == 2 && app.mineCooldown <= 0)
                disp('不给');
                ret = false;
                return;
            end
            foodCost = app.fetch('food_con');
            waterCost = app.fetch('water_con');
            app.food = app.food - foodCost(app.weathers(app.day)) * 3;
            app.water = app.water - waterCost(app.weathers(app.day)) * 3;
            app.money = app.money + app.fetch('income');
            app.day = app.day + 1;
            ret = true;
        end
        
        function completed(app)
            app.money = app.money + app.fetch('food_price') * app.food * 0.5;
            app.money = app.money + app.fetch('water_price') * app.water * 0.5;
            app.food = 0;
            app.water = 0;
        end

        function ret = indexof(~, arr, p)
            sz = size(arr);
            for i = 1 : sz(1)
                if arr(i, 1) == p
                    disp('found: ' + string(i));
                    ret = i;
                    return;
                end
            end
            ret = -1;
        end
        
        function ret = pathfind(app, s, t)
            ret = [];
            dist = 0;
            frontier = [[s -1 dist]];
            reached = zeros(0, 0);
            while ~isempty(frontier)
                current = frontier(1, :);
                id = current(1);
                frontier = frontier(2:end, :);
                neighbors = app.getNeighbors(id);
                idx = app.indexof(reached, current(1));
                if idx ~= -1 && reached(idx, 3) > current(3)
                    reached(idx, :) = [];
                end
                reached = [reached; current];
                dist = current(3) + 3;
                if app.reps(current(1)) == 1
                    dist = dist - 2;
                end
                if app.reps(current(1)) == 2
                    dist = dist - 1;
                end
                for i = 1 : length(neighbors)
                    idx = app.indexof(reached, neighbors(i));
                    if idx == -1
                        frontier = [frontier; [neighbors(i) id dist]];
                    end
                end
            end
            % find optimal path
            idx = app.indexof(reached, t);
            if idx == -1
                disp('没路走');
                ret = [];
                return;
            end
            current = reached(idx, :);
            while current(2) ~= -1
                ret = [ret current(1)];
                found = false;
                sz = size(reached);
                for i = 1 : sz(1)
                    if reached(i, 1) == current(2)
                        current = reached(i, :);
                        found = true;
                        break;
                    end
                end
                if ~found
                    disp('路断了');
                    return;
                end
            end
            ret = [ret current(1)];
            return;
        end
        
        function ret = getNeighbors(app, s)
            ret = [];
            for i = 1 : length(app.m)
                if app.m(s, i) == 1
                    ret = [ret i];
                end
            end
        end
        
        % This could only be used when weather is known.
        % Path should be reversed - so the dijkstra result could be plugged
        % directly. Returns (food, water, day)
        function ret = estimateResources(app, day, path)
            daysPassed = 0;
            foodCost = 0;
            waterCost = 0;
            foodCon = app.fetch('food_con');
            waterCon = app.fetch('water_con');
            i = length(path) - 1;
            while i >= 1
                wotd = app.weathers(day);
                if wotd == 3
                    daysPassed = daysPassed + 1;
                    day = day + 1;
                    foodCost = foodCost + foodCon(wotd);
                    waterCost = waterCost + waterCon(wotd);
                    continue;
                end
                foodCost = foodCost + foodCon(wotd) * 2;
                waterCost = waterCost + waterCon(wotd) * 2;
                day = day + 1;
                daysPassed = daysPassed + 1;
                i = i - 1;
            end
            ret = [foodCost waterCost daysPassed];
        end
        
        function ret = estimateMineCost(app, day, duration)
            foodCon = app.fetch('food_con');
            waterCon = app.fetch('water_con');
            foodCost = 0;
            waterCost = 0;
            % can't mine for the first day
            foodCost = foodCon(app.weathers(day));
            waterCost = waterCon(app.weathers(day));
            day = day + 1;
            for i = 1 : (duration - 1)
                disp(duration);
                foodCost = foodCost + foodCon(app.weathers(day)) * 3;
                waterCost = waterCost + waterCon(app.weathers(day)) * 3;
                day = day + 1;
            end
            ret = [foodCost waterCost];
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            clc;
            T = readtable('data/challenge.4.csv');
            arr = table2array(T);
            app.labels = strings(arr(length(arr), 1), 1);
            app.reps = zeros(arr(length(arr), 1), 1);
            for i = 1 : length(arr)
                id = arr(i, 1);
                switch arr(i, 3)
                    case 0
                        app.labels(id) = string(id);
                        app.reps(id) = 0;
                    case 1
                        app.labels(id) = strcat('村庄 ', string(id));
                        app.reps(id) = 1;
                        if ~any(app.villages(:) == id)
                            app.villages = [app.villages id];
                        end
                    case 2
                        app.labels(id) = strcat('矿山 ', string(id));
                        app.reps(id) = 2;
                        if ~any(app.mines(:) == id)
                            app.mines = [app.mines id];
                        end
                    case 3
                        app.labels(id) = strcat('终点 ', string(id));
                        app.reps(id) = 3;
                        app.terminal = id;
                    otherwise
                        app.labels(id) = strcat('不知道 ', string(id));
                end
                app.m(id, arr(i, 2)) = 1;
                app.m(arr(i, 2), id) = 1;
            end
            app.parameters = readtable('data/parameters.2.csv');
            app.weathers = table2array(readtable('data/weathers.2.1.csv'));
            app.food = app.parameters(1, 'food').(1);
            app.water = app.parameters(1, 'water').(1);
            app.money = app.parameters(1, 'money').(1);
            app.render();
            
            app.t.days = zeros(30, 1);
            app.t.areas = zeros(30, 1);
            app.t.money = zeros(30, 1);
            app.t.water = zeros(30, 1);
            app.t.food = zeros(30, 1);
        end

        % Button pushed function: Button
        function ButtonPushed(app, event)
            input = app.EditField.Value;
            strsplit(input, ",");
            input = str2num(input);
            
            app.m(input(1, 1), input(1, 2)) = 1;
            app.m(input(1, 2), input(1, 1)) = 1;
            app.render();
        end

        % Button pushed function: Button_2
        function Button_2Pushed(app, event)
            app.m = [];
            app.render();
        end

        % Button pushed function: Button_3
        function Button_3Pushed(app, event)
            waterCount = str2num(app.EditField_2.Value);
            foodCount = str2num(app.EditField_3.Value);
            app.purchase(foodCount, waterCount);
            app.render();
        end

        % Button pushed function: Button_4
        function Button_4Pushed(app, event)
            data = {(app.day - 1), app.node, app.money, app.water, app.food};
            app.t(app.day, :) = data;
            app.pass();
            app.render();
        end

        % Button pushed function: Button_5
        function Button_5Pushed(app, event)
            dest = app.DropDown.Value;
            data = {(app.day - 1), app.node, app.money, app.water, app.food};
            app.t(app.day, :) = data;
            app.travel(dest);
            app.render();
        end

        % Button pushed function: Button_6
        function Button_6Pushed(app, event)
            data = {(app.day - 1), app.node, app.money, app.water, app.food};
            app.t(app.day, :) = data;
            app.mine();
            app.render();
        end

        % Button pushed function: Button_7
        function Button_7Pushed(app, event)
            input = app.DijkstraEditField.Value;
            strsplit(input, ",");
            input = str2num(input);
            app.dijkstra = app.pathfind(input(1), input(2));
            offset = app.day;
            if length(input) == 3
                offset = input(3);
            end
            
            n = zeros(size(app.m));
            for i = 1 : length(app.dijkstra) - 1
                n(app.dijkstra(i), app.dijkstra(i + 1)) = 1;
                n(app.dijkstra(i + 1), app.dijkstra(i)) = 1;
            end
            app.path = graph(n, 'upper', 'omitselfloops');
            res = app.estimateResources(offset, app.dijkstra);
            app.Label_10.Text = '走过去需要 ' + string(res(3)) + ' 天，食物 ' + string(res(1)) + ' , 水' + string(res(2));
            app.render();
        end

        % Button pushed function: Button_8
        function Button_8Pushed(app, event)
            app.day = str2num(app.EditField_4.Value);
            app.render();
        end

        % Button pushed function: Button_9
        function Button_9Pushed(app, event)
            app.node = str2num(app.EditField_5.Value);
            app.render();
        end

        % Button pushed function: Button_10
        function Button_10Pushed(app, event)
            waterCount = str2num(app.EditField_6.Value);
            foodCount = str2num(app.EditField_7.Value);
            app.food = app.food + foodCount;
            app.water = app.water + waterCount;
            app.render();
        end

        % Button pushed function: Button_11
        function Button_11Pushed(app, event)
            input = app.EditField_8.Value;
            strsplit(input, ",");
            input = str2num(input);
            offset = app.day;
            if length(input) == 2
                offset = input(2);
            end
            c = app.estimateMineCost(offset, input(1));
            disp(c);
            warning = '';
            if c(1) * app.fetch('food_wgt') + c(2) * app.fetch('water_wgt') > app.fetch('encumbrance')
                warning = '超重。';
            end
            app.Label_16.Text = string(warning) + '需要 ' + string(c(1)) + ' 食物和 ' + string(c(2)) + ' 水';
        end

        % Button pushed function: Button_12
        function Button_12Pushed(app, event)
            writetable(app.t, 'out.csv', 'Delimiter', ';');
        end

        % Button pushed function: Button_13
        function Button_13Pushed(app, event)
            input = app.DijkstraEditField.Value;
            strsplit(input, ",");
            input = str2num(input);
            ret = app.pathfind(input(1), input(2));
            disp(app.dijkstra);
            app.dijkstra = [ret app.dijkstra];
            disp(app.dijkstra);
            offset = app.day;
            if length(input) == 3
                offset = input(3);
            end
            
            n = zeros(size(app.m));
            for i = 1 : length(app.dijkstra) - 1
                n(app.dijkstra(i), app.dijkstra(i + 1)) = 1;
                n(app.dijkstra(i + 1), app.dijkstra(i)) = 1;
            end
            app.path = graph(n, 'upper', 'omitselfloops');
            app.render();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 666 624];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.PlotBoxAspectRatio = [2.72972972972973 1 1];
            app.UIAxes.Position = [1 347 655 278];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [14 45 53 22];
            app.Label.Text = '加邻接点';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.Position = [82 45 221 22];

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Position = [310 44 100 25];
            app.Button.Text = '加';

            % Create Button_2
            app.Button_2 = uibutton(app.UIFigure, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
            app.Button_2.Position = [14 12 396 25];
            app.Button_2.Text = '清除所有';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.Position = [8 324 396 24];
            app.Label_2.Text = '这里会出现废话';

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.Position = [8 296 396 22];
            app.Label_3.Text = '天气之类的玩意儿';

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [452 317 29 22];
            app.Label_4.Text = '买水';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.UIFigure, 'text');
            app.EditField_2.Position = [496 317 100 22];

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [440 286 41 22];
            app.Label_5.Text = '买吃的';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.UIFigure, 'text');
            app.EditField_3.Position = [496 286 100 22];

            % Create Button_3
            app.Button_3 = uibutton(app.UIFigure, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
            app.Button_3.Position = [603 286 53 53];
            app.Button_3.Text = '买';

            % Create Button_4
            app.Button_4 = uibutton(app.UIFigure, 'push');
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @Button_4Pushed, true);
            app.Button_4.Position = [8 225 125 25];
            app.Button_4.Text = '逗留';

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.Position = [8 255 65 22];
            app.Label_6.Text = '你要干啥？';

            % Create Button_5
            app.Button_5 = uibutton(app.UIFigure, 'push');
            app.Button_5.ButtonPushedFcn = createCallbackFcn(app, @Button_5Pushed, true);
            app.Button_5.Position = [166 191 100 25];
            app.Button_5.Text = '出发';

            % Create Label_9
            app.Label_9 = uilabel(app.UIFigure);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.Position = [8 192 29 22];
            app.Label_9.Text = '前往';

            % Create DropDown
            app.DropDown = uidropdown(app.UIFigure);
            app.DropDown.Items = {};
            app.DropDown.Position = [52 192 100 22];
            app.DropDown.Value = {};

            % Create Button_6
            app.Button_6 = uibutton(app.UIFigure, 'push');
            app.Button_6.ButtonPushedFcn = createCallbackFcn(app, @Button_6Pushed, true);
            app.Button_6.Position = [143 225 125 25];
            app.Button_6.Text = '挖矿';

            % Create DijkstraEditFieldLabel
            app.DijkstraEditFieldLabel = uilabel(app.UIFigure);
            app.DijkstraEditFieldLabel.HorizontalAlignment = 'right';
            app.DijkstraEditFieldLabel.Position = [21 74 46 22];
            app.DijkstraEditFieldLabel.Text = 'Dijkstra';

            % Create DijkstraEditField
            app.DijkstraEditField = uieditfield(app.UIFigure, 'text');
            app.DijkstraEditField.Position = [82 74 221 22];

            % Create Button_7
            app.Button_7 = uibutton(app.UIFigure, 'push');
            app.Button_7.ButtonPushedFcn = createCallbackFcn(app, @Button_7Pushed, true);
            app.Button_7.Position = [310 71 49 25];
            app.Button_7.Text = '找';

            % Create Label_10
            app.Label_10 = uilabel(app.UIFigure);
            app.Label_10.Position = [419 72 237 22];
            app.Label_10.Text = '';

            % Create Label_11
            app.Label_11 = uilabel(app.UIFigure);
            app.Label_11.HorizontalAlignment = 'right';
            app.Label_11.Position = [428 255 53 22];
            app.Label_11.Text = '设置天数';

            % Create EditField_4
            app.EditField_4 = uieditfield(app.UIFigure, 'text');
            app.EditField_4.Position = [496 255 100 22];

            % Create Button_8
            app.Button_8 = uibutton(app.UIFigure, 'push');
            app.Button_8.ButtonPushedFcn = createCallbackFcn(app, @Button_8Pushed, true);
            app.Button_8.Position = [603 252 53 25];
            app.Button_8.Text = '好';

            % Create Label_12
            app.Label_12 = uilabel(app.UIFigure);
            app.Label_12.HorizontalAlignment = 'right';
            app.Label_12.Position = [454 226 29 22];
            app.Label_12.Text = '瞬移';

            % Create EditField_5
            app.EditField_5 = uieditfield(app.UIFigure, 'text');
            app.EditField_5.Position = [498 226 100 22];

            % Create Button_9
            app.Button_9 = uibutton(app.UIFigure, 'push');
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @Button_9Pushed, true);
            app.Button_9.Position = [603 223 53 25];
            app.Button_9.Text = '好';

            % Create Button_10
            app.Button_10 = uibutton(app.UIFigure, 'push');
            app.Button_10.ButtonPushedFcn = createCallbackFcn(app, @Button_10Pushed, true);
            app.Button_10.Position = [605 161 53 53];
            app.Button_10.Text = '拿';

            % Create Label_13
            app.Label_13 = uilabel(app.UIFigure);
            app.Label_13.HorizontalAlignment = 'right';
            app.Label_13.Position = [454 192 29 22];
            app.Label_13.Text = '拿水';

            % Create EditField_6
            app.EditField_6 = uieditfield(app.UIFigure, 'text');
            app.EditField_6.Position = [498 192 100 22];

            % Create Label_14
            app.Label_14 = uilabel(app.UIFigure);
            app.Label_14.HorizontalAlignment = 'right';
            app.Label_14.Position = [442 161 41 22];
            app.Label_14.Text = '拿吃的';

            % Create EditField_7
            app.EditField_7 = uieditfield(app.UIFigure, 'text');
            app.EditField_7.Position = [498 161 100 22];

            % Create Button_11
            app.Button_11 = uibutton(app.UIFigure, 'push');
            app.Button_11.ButtonPushedFcn = createCallbackFcn(app, @Button_11Pushed, true);
            app.Button_11.Position = [310 101 100 25];
            app.Button_11.Text = '找';

            % Create Label_15
            app.Label_15 = uilabel(app.UIFigure);
            app.Label_15.HorizontalAlignment = 'right';
            app.Label_15.Position = [14 104 53 22];
            app.Label_15.Text = '挖矿计算';

            % Create EditField_8
            app.EditField_8 = uieditfield(app.UIFigure, 'text');
            app.EditField_8.Position = [82 104 221 22];

            % Create Label_16
            app.Label_16 = uilabel(app.UIFigure);
            app.Label_16.Position = [419 104 237 22];
            app.Label_16.Text = '';

            % Create Button_12
            app.Button_12 = uibutton(app.UIFigure, 'push');
            app.Button_12.ButtonPushedFcn = createCallbackFcn(app, @Button_12Pushed, true);
            app.Button_12.Position = [8 132 402 25];
            app.Button_12.Text = '输出行程';

            % Create Button_13
            app.Button_13 = uibutton(app.UIFigure, 'push');
            app.Button_13.ButtonPushedFcn = createCallbackFcn(app, @Button_13Pushed, true);
            app.Button_13.Position = [359 72 52 24];
            app.Button_13.Text = '加';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = main

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end