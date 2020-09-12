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
        dist = current(3) + 2;
        if app.reps(current(1)) == 1
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