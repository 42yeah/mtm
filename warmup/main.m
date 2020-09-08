function main()
    clear_stuffs();

%     unfinished = readtable('data/unfinished.csv');
     finished = readtable('data/finished.csv');
     users = readtable('data/users.csv');

    ax = worldmap('China');
    land = shaperead('landareas', 'UseGeoCoords', true);
    geoshow(ax, land, 'FaceColor', [0.5 0.7 0.5])
    lakes = shaperead('worldlakes', 'UseGeoCoords', true);
    geoshow(lakes, 'FaceColor', 'blue');
    rivers = shaperead('worldrivers', 'UseGeoCoords', true);
    geoshow(rivers, 'Color', 'blue');
    cities = shaperead('worldcities', 'UseGeoCoords', true);
    disp(struct2table(cities));
    finished_tasks = table2array(finished(:, [2, 3]));
    S = array_to_struct(finished_tasks);
    geoshow(S, 'Color', 'blue');
    
    % process user data
    for i = 1:height(users)
        grid = users(i, 2);
        users(i, 2) = strsplit(grid, ' ');
        disp(users(i, 2));
    end
    users = table2array(users(:, [2, 3]));
    
    S = array_to_struct(users);
    geoshow(S, 'Color', 'blue');
end

function ret = array_to_struct(what)
    T = array2table(what, 'VariableNames', ["Lat" "Lon"]);
    T.Geometry = repmat({'Point'}, height(T), 1);
    ret = table2struct(T);
end

function clear_stuffs()
    clc;
    clear;
end


