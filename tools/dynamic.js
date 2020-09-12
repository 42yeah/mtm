let map = [];

function pos(x, y) {
    return { x, y };
}

function player() {
    return {
        position: pos(0, 0),
        food: 0,
        water: 0,
        total: 0
    };
}

function mapPos(pos) {
    return map[pos.y][pos.x];
}

function getNeighbors(chunk) {
    let ret = [];
    if (chunk.position.y > 0) {
        ret.push(mapPos(pos(chunk.position.x, chunk.position.y - 1)));
    }
    if (chunk.position.y < 4) {
        ret.push(mapPos(pos(chunk.position.x, chunk.position.y + 1)));
    }
    if (chunk.position.x > 0) {
        ret.push(mapPos(pos(chunk.position.x - 1, chunk.position.y)));
    }
    if (chunk.position.x < 4) {
        ret.push(mapPos(pos(chunk.position.x + 1, chunk.position.y)));
    }
    return ret;
}

function renewMap() {
    for (let y = 0; y < 5; y++) {
        map.push([]);
        for (let x = 0; x < 5; x++) {
            let weight = 3;
            if (x == 3 && y == 2) {
                weight = 1; // Village
            }
            if (x == 2 && y == 3) {
                weight = 2; // Mine
            }
            for (let i = 0; i < players.length; i++) {
                if (players[i].position.x == x && players[i].position.y == y) {
                    weight += 50;
                }
            }
            map[y].push({
                totalWeight: 0,
                prev: null,
                weight: weight,
                position: pos(x, y)
            });
        }
    }    
}

function pathfind(s, t) {
    renewMap();
    s = mapPos(s);
    s.weight = 1; // We are leaving here
    s.totalWeight += s.weight;
    let frontier = [ s ];
    let done = [ s ];

    while (frontier.length > 0) {
        let current = frontier[0];
        frontier.splice(0, 1);
        let neighbors = getNeighbors(current);
        // Any neighbors in done? Check it; if there's not, add it. If there is, optimize it.
        for (let i = 0; i < neighbors.length; i++) {
            let neighbor = neighbors[i];
            let totalWeight = current.totalWeight + neighbor.weight;
            if (done.indexOf(neighbor) == -1) {
                neighbor.totalWeight = totalWeight;
                neighbor.prev = current;
                frontier.push(neighbor);
                done.push(neighbor);
            } else if (neighbor.totalWeight > totalWeight && current.prev != neighbor) {
                neighbor.totalWeight = totalWeight;
                neighbor.prev = current;
                frontier.push(neighbor);
            }
        }
    }
    let terminal = mapPos(t);
    if (terminal.prev == null) {
        return null;
    }
    let path = [];
    while (terminal.prev != null) {
        path.splice(0, 0, terminal);
        terminal = terminal.prev;
    }
    path.splice(0, 0, terminal);
    return path;
}

// Think with computer. What would an AI do?
function think() {
}

let players = [ player(), player(), player() ];
