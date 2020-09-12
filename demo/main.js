const days = document.querySelector("#days");
let startFoodInput = document.querySelector("#start_food");
let startWaterInput = document.querySelector("#start_water");

let weathers = [
    2, 2, 1, 3, 1, 2, 3, 1, 2, 2, 3, 2, 1, 2, 2, 2, 3, 3, 2, 2, 1, 1, 2, 1, 3, 2, 1, 1, 2, 2
];

let weatherDict = [
    "晴天",
    "炎热",
    "沙尘暴"
];

let costMap = {
    food: [7, 6, 10],
    water: [5, 8, 10]
};

let baseCost = {
    food: 122,
    water: 130
};

let price = {
    food: 10,
    water: 5
};

let day = 10; // Arrives at day 10, which is a stormy day

function renderTickboxes(count) {
    let elem = document.querySelector("#tickboxes");
    let html = "";
    for (let i = 0; i < count; i++) {
        html += "<input type=\"checkbox\" id=\"t" + (day + i) + "\" target=\"" + (day + i) + "\" onchange=\"calculateCost()\">";
        html += "<label for=\"t" + (day + i) + "\">" + weatherDict[weathers[day + i] - 1] + "</label>";
    }
    elem.innerHTML = html;
    calculateCost();
}

function max(a, b) {
    return a > b ? a : b;
}

function min(a, b) {
    return a < b ? a : b;
}

function isOverweight(food, water) {
    console.log("isOverweight: ", food, water, food * 2 + water * 3);
    return (food * 2 + water * 3) > 1200;
}

function calculateCost() {
    let totalCost = {
        food: baseCost.food, 
        water: baseCost.water
    };
    let mineCost = {
        food: 24,
        water: 32
    }
    let elems = document.querySelectorAll("[type=\"checkbox\"]");
    let earnings = 0;
    for (let i = 0; i < elems.length; i++) {
        let targetDay = elems[i].getAttribute("target");
        let multiplier = elems[i].checked ? 3 : 1;
        if (elems[i].checked) {
            earnings += 1000;
        }
        totalCost.food += costMap.food[weathers[targetDay] - 1] * multiplier;
        totalCost.water += costMap.water[weathers[targetDay] - 1] * multiplier;
        mineCost.food += costMap.food[weathers[targetDay] - 1] * multiplier;
        mineCost.water += costMap.water[weathers[targetDay] - 1] * multiplier;
    }
    // Now do the post-days - we need to go back!
    let aftermath = day + elems.length;
    let dist = 5;
    while (dist > 0) {
        if (weathers[aftermath] == 3) {
            // Uh oh, sandstorm!
            totalCost.food += costMap.food[weathers[aftermath] - 1];
            totalCost.water += costMap.water[weathers[aftermath] - 1];
            aftermath++;
            if (dist > 3) {
                // Not arrived at village... Yet.
                mineCost.food += costMap.food[weathers[aftermath] - 1];
                mineCost.water += costMap.water[weathers[aftermath] - 1];
            }
            continue;
        }
        totalCost.food += costMap.food[weathers[aftermath] - 1] * 2;
        totalCost.water += costMap.water[weathers[aftermath] - 1] * 2;
        aftermath++;
        if (dist >= 3) {
            // Not arrived at village... Yet.
            mineCost.food += costMap.food[weathers[aftermath] - 1] * 2;
            mineCost.water += costMap.water[weathers[aftermath] - 1] * 2;
        }
        dist--;
    }
    
    let starterFood = +startFoodInput.value;
    let starterWater = +startWaterInput.value;
    let remainingFood = totalCost.food - starterFood;
    let remainingWater = totalCost.water - starterWater;
    let basePrice = starterFood * price.food + starterWater * price.water + remainingFood * price.food * 2 + remainingWater * price.water * 2;
    let profit = -basePrice + earnings;
    let prompt = "<br />下矿过程（从村出发到回村）所需要的食物: " + mineCost.food + "，水: " + mineCost.water;
    if (isOverweight(mineCost.food, mineCost.water)) {
        prompt += "<br />警告：你下矿所需要的食物和水已经超过了你能带的上限。";
    }
    if (isOverweight(starterFood, starterWater)) {
        prompt += "<br />警告：起点买的物资已经超过了能带的上限。";
    }
    if (starterFood < 98 || starterWater < 98) {
        prompt += "<br />警告：活不到村庄。";
    }
    let arrivedFood = starterFood - 98;
    let arrivedWater = starterWater - 98;
    let tbb = {
        food: max(mineCost.food - arrivedFood, 0),
        water: max(mineCost.water - arrivedWater, 0)
    }; // To be bought
    if (isOverweight(arrivedFood + tbb.food, arrivedWater + tbb.water)) {
        prompt += "<br />警告：在村庄买不完资源，因为背包太满。";
    }
    let advice = {
        food: totalCost.food,
        water: totalCost.water
    };
    // There is a high possibility that this is too much. If it is,
    if (isOverweight(advice.food, advice.water)) {
        // Prioritize food over water (because food is EXPENSIVE)
        let waterCount = min(max(Math.floor((1200 - totalCost.food * 2) / 3), 98), totalCost.water);
        let foodCount = min(max(Math.floor((1200 - waterCount * 3) / 2), 98), totalCost.food);
        advice = {
            food: foodCount,
            water: waterCount
        };
        // And if it still overweights, (how is that possible?)
        if (isOverweight(advice.food, advice.water)) {
            // Just don't give any bloody advice
            advice = {
                food: "无建议",
                water: "无建议"
            };
        }
    }
    tbb = {
        food: max(mineCost.food - (advice.food - 98), 0),
        water: max(mineCost.water - (advice.water - 98), 0)
    }; // To be bought
    // Now does this makes you unable to replenish water at the village?
    while (isOverweight(advice.food - 98 + tbb.food, advice.water - 98 + tbb.water)) {
        // If it is, decrease food for a bit so at least we can replenish water at the village
        let deltaspace = (advice.food - 98 + tbb.food) * 2 + (advice.water - 98 + tbb.water) * 3 - 1200;
        // With every two food decreased, one water could be bought at the start.
        // Which means with every two food, we need one less water.
        console.log("Too much. Delta space: ", deltaspace);
        console.log("Weight: ", (advice.food - 98 + tbb.food) * 2 + (98 + tbb.water) * 3);
        let deltaFood = Math.ceil(deltaspace / 2);
        advice.food -= deltaFood;

        deltaspace = deltaFood * 2;
        let deltaWater = Math.floor(deltaspace / 3);
        console.log(deltaFood, advice.food, deltaWater, advice.water);
        
        // With less food, we can actually buy *more* water at the start.
        advice.water += deltaWater;
        // Loop this until it is reasonable.
        tbb = {
            food: max(mineCost.food - (advice.food - 98), 0),
            water: max(mineCost.water - (advice.water - 98), 0)
        }; // To be bought
        if (advice.food < 0 || advice.water < 0 || advice.food > 10000 || advice.water > 10000) {
            console.log("Anomaly!");
            break;
        }
    }
    prompt += "<br />建议起点食物为 " + advice.food + ", " + advice.water;
    document.querySelector("#costs").innerHTML = "食物: " + totalCost.food + ", 水: " + totalCost.water + prompt;
    document.querySelector("#earnings").innerHTML = "基础价格 " + basePrice + ". 挖矿获得 " + earnings + ", 利润为 " + profit + ", 到达终点钱为 " + (10000 + profit);
}

days.addEventListener("change", (e) => {
    let data = days.value;
    if (isFinite(data)) {
        renderTickboxes(+data);
    }
});
