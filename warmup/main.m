function main()
    clear_stuffs();
%     unfinished = readtable("data/unfinished.csv");
     finished = readtable("data/finished.csv");
%     users = readtable("data/users.csv");

    ax = worldmap("China");
    land = shaperead('landareas', 'UseGeoCoords', true);
    geoshow(ax, land, 'FaceColor', [0.5 0.7 0.5])
    lakes = shaperead('worldlakes', 'UseGeoCoords', true);
    geoshow(lakes, 'FaceColor', 'blue');
    rivers = shaperead('worldrivers', 'UseGeoCoords', true);
    geoshow(rivers, 'Color', 'blue');
    cities = shaperead('worldcities', 'UseGeoCoords', true);
    disp(struct2table(cities));
    finished_tasks = table2array(finished(:, [2, 3]));
    T = array2table(finished_tasks, "VariableNames", ["Lat" "Lon"]);
    T.Geometry = repmat({'Point'}, height(T), 1);
    disp(T);
    S = table2struct(T);
    geoshow(S, 'Color', 'blue');
end

function clear_stuffs()
    clc;
    clear;
end


