let map = [];

function pos(x, y) {
    return { x, y };
}

function player() {
    return {
        position: pos(0, 0),
        food: 0,
        water: 0,
        money: 10000,
        thought: "",
        action: null,
        day: 0,
        disqualified: false,
        finished: false,
        mined: false,
        packed: false
    };
}

function isOverweight(player) {
    return (player.food * 2 + player.water * 3) > 1200;
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
    map = [];
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

let weatherBar = [0.4835, 0.4835, 0.033];
let costMap = {
    food: [3, 9, 10],
    water: [4, 9, 10]
};
let mean = {
    food: Math.ceil(costMap.food[0] * weatherBar[0] + costMap.food[1] * weatherBar[1] + costMap.food[2] * weatherBar[2]),
    water: Math.ceil(costMap.water[0] * weatherBar[0] + costMap.water[1] * weatherBar[1] + costMap.water[2] * weatherBar[2])
};
let price = {
    food: 10,
    water: 5
};
let score = 0;

function bar(chance) {
    for (let i = 0; i < weatherBar.length; i++) {
        chance -= weatherBar[i];
        if (chance < 0) {
            return i;
        }
    }
    return weatherBar[weatherBar.length - 1];
}

let wotd = 0; // Weather should be randomized at the beginning

// Action is divided into two parts: type, position.
// "dig" and "wait" doesn't need position per se, however go needs it.

function meanRequirement(days) {
    return {
        food: Math.ceil(mean.food * days) * 2,
        water: Math.ceil(mean.water * days) * 2
    };
}

function duration(path) {
    return path ? path.length - 1 : 0;
}

function daysToLast(player) {
    let foodDays = Math.floor(player.food / mean.food);
    let waterDays = Math.floor(player.water / mean.water);
    return foodDays < waterDays ? foodDays : waterDays;
}

function max(a, b) { 
    return a > b ? a : b;
}

function min(a, b) {
    return a < b ? a : b;
}

// Think with computer. What would an AI do?
function think(player) {
    let onShopSquare = player.day == 0 || (player.position.x == 3 && player.position.y == 2);
    let priceMultiplier = player.day == 0 ? 1 : 2;
    let onMineSquare = player.position.x == 2 && player.position.y == 3;
    let pathToFin = pathfind(player.position, pos(4, 4));
    let pathToShop = pathfind(player.position, pos(3, 2));
    let pathToMine = pathfind(player.position, pos(2, 3));
    let mineToShop = pathfind(pos(2, 3), pos(3, 2));
    let spareDays = 1;

    // If the food can't last any longer, then they has to hit the shop NOW
    if (!player.packed && (daysToLast(player) / 2 <= duration(pathToShop) + spareDays || player.mined && duration(pathToFin + spareDays) >= daysToLast(player) / 2)) {
        player.thought = "buy stuffs";
        if (onShopSquare) {
            if (duration(pathToMine) + spareDays >= (30 - player.day) || player.mined) {
                // There is no time to mine now. Gotta go.
                player.packed = true;
                let req = meanRequirement(duration(pathToFin) + spareDays);
                // Perform purchase
                let dFood = max(req.food - player.food, 0);
                let dWater = max(req.water - player.water, 0);
                player.food += dFood;
                player.water += dWater;
                player.money -= dFood * price.food * priceMultiplier + dWater * price.water * priceMultiplier;
            } else {
                // Hey look, we can hit the mine. Let's do it!
                let req = meanRequirement(duration(pathToMine) + duration(mineToShop) + spareDays);
                let dFood = max(req.food - player.food, 0);
                let dWater = max(req.water - player.water, 0);
                player.food += dFood;
                player.water += dWater;
                player.money -= dFood * price.food * priceMultiplier + dWater * price.water * priceMultiplier;

                // Now take a look at how many days we can dig
                while (!isOverweight(player)) {
                    player.food += mean.food;
                    player.water += mean.water;
                    player.money -= mean.food * price.food * priceMultiplier + mean.water * price.water * priceMultiplier;
                }
                // And when they are, sell a day worth of food & water
                player.food -= mean.food;
                player.water -= mean.water;
                player.money += mean.food * price.food * priceMultiplier + mean.water * price.water * priceMultiplier;
                // And when we are at the start, use food to stuff the bag
                if (priceMultiplier == 1) {
                    while (!isOverweight(player)) {
                        player.food += 1;
                        player.money -= 1 * price.food * priceMultiplier;
                    }
                    player.food -= 1;
                    player.money += 1 * price.food * priceMultiplier;
                }
            }
        } else {
            if (player.action.type == "mine") {
                player.mined = true;
            }
            // Walk towards it
            player.action = {
                type: "go",
                position: pathToShop[1].position
            };
            return;
        }
    }
    if ((30 - player.day) <= duration(pathToFin) + spareDays || player.mined || player.packed) {
        // Gotta go!
        player.action = {
            type: "go",
            position: pathToFin[1].position
        };
        player.thought = "to finish!";
        return;
    }
    if (onMineSquare) {
        player.action = {
            type: "mine",
            position: null
        };
        player.thought = "mining money";
        return;
    }
    if (meanRequirement(duration(pathToMine) + duration(mineToShop) + spareDays) > daysToLast(player)) {
        // Can't mine - need to buy more!
        player.action = {
            type: "go",
            position: pathToShop[1].position
        };
        player.thought = "to shop";
        return;
    }
    // Otherwise - to the mines!
    player.action = {
        type: "go",
        position: pathToMine[1].position
    };
    player.thought = "to mines!";
}

function action(player) {
    // Avoid at the same tile at all costs
    renewMap();
    switch (player.action.type) {
        case "go":
            if (mapPos(player.action.position).weight >= 50 || wotd == 2) {
                // Just stay here; It's too much.
                player.food -= costMap.food[wotd];
                player.water -= costMap.water[wotd];
            } else {
                player.position = pos(player.action.position.x, player.action.position.y);
                player.food -= costMap.food[wotd] * 2;
                player.water -= costMap.water[wotd] * 2;
            }
            break;

        case "stay":
            player.food -= costMap.food[wotd];
            player.water -= costMap.water[wotd];
            break;

        case "mine":
            if (player.position.x != 2 || player.position.y != 3) {
                console.log("ERR! The player is trying to mine while NOT being in the mine");
                break;
            }
            player.food -= costMap.food[wotd] * 3;
            player.water -= costMap.water[wotd] * 3;
            player.money += 1000;
            break;
    }
    if (player.food < 0 || player.water < 0 || player.day >= 30) {
        console.log("Player DISQUALIFIED");
        player.disqualified = true;
    }
    if (player.position.x == 4 && player.position.y == 4 && !player.disqualified) {
        console.log("Player ARRIVED");
        player.finished = true;
    }
    player.day++;
}

let players = [ player(), player(), player() ];

function turn() {
    wotd = bar(Math.random());
    for (let i = 0; i < players.length; i++) {
        let player = players[i];
        think(player);
        action(player);
        if (player.disqualified) {
            console.log("Player", i, "is disqualified");
            players.splice(i, 1);
            i--;
            continue;
        }
        if (player.finished) {
            let total = player.food * price.food * 0.5 + player.water * price.water * 0.5 + player.money;
            console.log("Player", i, "finished with $", total);
            players.splice(i, 1);
            score += total;
            i--;
            continue;
        }
    }
    let output = "";
    for (let y = 0; y < 5; y++) {
        for (let x = 0; x < 5; x++) {
            let hasPlayer = false;
            for (let i = 0; i < players.length; i++) {
                let player = players[i];
                if (player.position.x == x && player.position.y == y) {
                    output += i;
                    hasPlayer = true;
                    break;
                }
            }
            if (!hasPlayer) {
                if (x == 3 && y == 2) {
                    output += "^";
                } else if (x == 2 && y == 3) {
                    output += "$";
                } else {
                    output += ".";
                }
            }
        }
        output += "\n";
    }
    console.log(output);
    for (let i = 0; i < players.length; i++) {
        console.log("Player " + i + ":", players[i]);
    }
    console.log("Score:", score);
}

renewMap();

function reset() {
    score = 0;
    players = [ player(), player(), player() ];
    players[2].mined = true;
}

let data = [];

function test(samples) {
    let sum = 0;
    let high = 0;
    for (let i = 0; i < samples; i++) {
        reset();
        while (players.length > 0) {
            turn();
        }
        data.push(score);
        sum += score;
        console.log("E = ", sum / (i + 1));   
        if (score > high) {
            high = score;
        } 
    }
    let str = "";
    for (let i = 0; i < samples; i++) {
        str += data[i] + "\n";
    }
    console.log(str);
    console.log("E = ", sum / samples, " HI = ", high);
}
