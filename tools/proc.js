let procs = [];
let results = [];

let costMap = {
    food: [3, 9, 10],
    water: [4, 9, 10]
};

let initialPrice = {
    food: 10,
    water: 5
};

// Monte Carlo Weather
let weatherBar = [0.4835, 0.4835, 0.033];

function add() {
    let radios = document.querySelectorAll("[name='type']");
    let type = 0;
    for (let i = 0; i < radios.length; i++) {
        if (radios[i].checked) {
            type = +(radios[i].value);
        }
    }
    let daysElem = document.querySelector("#days");
    procs.push({
        days: +daysElem.value,
        proc: type
    });
    daysElem.value = "";
    renderProcs();
}

function renderProcs() {
    let html = "";
    for (let i = 0; i < procs.length; i++) {
        html += "[";
        switch (procs[i].proc) {
            case 0:
                html += "走 ";
                break;

            case 1:
                html += "逗留 ";
                break;

            case 2:
                html += "挖 ";
                break;

            case 3:
                html += "检查点]";
                document.querySelector("#procs").innerHTML = html;
                continue;
        }
        html += procs[i].days + " 天]";
    }
    document.querySelector("#procs").innerHTML = html;
}

function splice() {
    let daysElem = document.querySelector("#days");
    let value = +daysElem.value;
    procs.splice(value, 1);
    renderProcs();
}

function bar(chance) {
    for (let i = 0; i < weatherBar.length; i++) {
        chance -= weatherBar[i];
        if (chance < 0) {
            return i;
        }
    }
    return weatherBar[weatherBar.length - 1];
}

function simpleMonteCarlo() {
    let total = {
        food: 0,
        water: 0,
        days: 0,
        money: 0,
        valid: true,
        startingFood: 0,
        startingWater: 0
    };
    let check = {
        food: 0,
        water: 0
    };
    let price = {
        food: initialPrice.food,
        water: initialPrice.water
    };
    let remainingWeight = 0;
    let firstCheck = false;
    for (let i = 0; i < procs.length; i++) {
        let proc = procs[i].proc;
        let days = procs[i].days;
        if (proc == 3) {
            // Checkpoint reached!
            // Let's see if he survives first...
            if (check.food * 2 + check.water * 3 > 1200) {
                // Disqualified
                total.valid = false;
                return total;
            }
            if (!firstCheck) {
                remainingWeight = 1200 - check.food * 2 - check.water * 3;
                firstCheck = true;
            }
            check.food = 0;
            check.water = 0;
            continue;
        }
        for (let j = 0; j < days; j++) {
            let wotd = bar(Math.random());
            let foodCost = costMap.food[wotd];
            let waterCost = costMap.water[wotd];
            if (wotd == 2 && proc == 0) {
                // Nope, can't do that.
                j--;
            }
            switch (proc) {
                case 0:
                    foodCost = foodCost * (wotd == 2 ? 1 : 2);
                    waterCost = waterCost * (wotd == 2 ? 1 : 2);
                    total.food += foodCost;
                    total.water += waterCost;
                    check.food += foodCost;
                    check.water += waterCost;
                    total.money += foodCost * price.food + waterCost * price.water;
                    break;
                
                case 1:
                    total.food += foodCost;
                    total.water += waterCost;
                    check.food += foodCost;
                    check.water += waterCost;
                    total.money += foodCost * price.food + waterCost * price.water;
                    break;

                case 2:
                    total.food += foodCost * 3;
                    total.water += waterCost * 3;
                    check.food += foodCost * 3;
                    check.water += waterCost * 3;
                    total.money += foodCost * 3 * price.food + waterCost * 3 * price.water;
                    total.money -= 200;
                    break;
            }
            if (firstCheck) {
                // Prioritze on FOOD
                if (remainingWeight - foodCost * 2 < 0 && remainingWeight >= 0) {
                    let overflown = Math.ceil(-(remainingWeight - foodCost * 2) / 2);
                    total.startingFood = total.food - overflown;
                    total.money += price.food * overflown;
                }
                remainingWeight -= foodCost * 2;
                // Then water
                if (remainingWeight - waterCost * 3 < 0 && remainingWeight >= 0) {
                    let overflown = Math.ceil(-(remainingWeight - waterCost * 3) / 3);
                    total.startingWater = total.water - overflown;
                    total.money += price.water * overflown;
                }
                remainingWeight -= waterCost * 3;
            }
            
            total.days++;
        }
    }
    if (check.food * 2 + check.water * 3 > 1200) {
        // Disqualified
        total.valid = false;
    }
    if (total.startingFood == 0) {
        total.startingFood = total.food;
    }
    if (total.startingWater == 0) {
        total.startingWater = total.water;
    }
    total.money = 10000 - total.money;
    return total;
}

function simulate() {
    results = [];
    let samples = +document.querySelector("#samples").value;
    for (let i = 0; i < samples; i++) {
        let r = simpleMonteCarlo();
        if (r.days <= 30 && r.valid) {
            results.push(r);
        }
    }
    let meanFood = 0;
    let meanWater = 0;
    let str = "food;water;days;money;sf;sw\n";
    for (let i = 0; i < results.length; i++) {
        let r = results[i];
        str += r.food + ";" + r.water + ";" + r.days + ";" + r.money + ";" + r.startingFood + ";" + r.startingWater + "\n";
        meanFood += r.startingFood;
        meanWater += r.startingWater;
    }
    document.querySelector("#rate").innerHTML = "存活率: " + (results.length / samples) + "<br />" +
        (meanFood) / results.length + ", " + (meanWater) / results.length;
    console.log(str);
}
