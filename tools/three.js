const days = document.querySelector("#days");
let startFoodInput = document.querySelector("#start_food");
let startWaterInput = document.querySelector("#start_water");

let weathers = [
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1
];

// let weathers = [
//     2, 2, 2, 2, 2, 2, 2, 2, 2, 2
// ];

// let weathers = [
//     1, 2, 1, 2, 1, 2, 1, 2, 1, 2
// ];

let weatherDict = [
    "晴天",
    "炎热",
    "沙尘暴"
];

let costMap = {
    food: [4, 9, 10],
    water: [3, 9, 10]
};

let price = {
    food: 10,
    water: 5
};

let day = 3; // Arrives at day 3

// Calculate the cost of walking
function calcCost(day, duration) {
    // There will be no sandstorm. Now that's convenient!
    let cost = {
        food: 0,
        water: 0
    };
    for (let i = 0; i < duration; i++) {
        cost.food += costMap.food[weathers[day + i] - 1] * 2;
        cost.water += costMap.water[weathers[day + i] - 1] * 2;
    }
    return cost;
}

let baseCost = calcCost(1, 3);
let distToFin = 2;

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
    return (food * 2 + water * 3) > 1200;
}

function calculateCost() {
    let totalCost = {
        food: baseCost.food, 
        water: baseCost.water
    };
    let elems = document.querySelectorAll("[type=\"checkbox\"]");
    let earnings = 0;
    for (let i = 0; i < elems.length; i++) {
        let targetDay = elems[i].getAttribute("target");
        let multiplier = elems[i].checked ? 3 : 1;
        if (elems[i].checked) {
            earnings += 200;
        }
        totalCost.food += costMap.food[weathers[targetDay] - 1] * multiplier;
        totalCost.water += costMap.water[weathers[targetDay] - 1] * multiplier;
    }
    let aftermath = day + elems.length;
    let dist = distToFin;
    let terminalCost = calcCost(aftermath, dist);
    totalCost.food += terminalCost.food;
    totalCost.water += terminalCost.water;
    let basePrice = totalCost.food * price.food + totalCost.water * price.water;
    let profit = -basePrice + earnings;
    let prompt = "";
    if (isOverweight(totalCost.food, totalCost.water)) {
        prompt += "<br />警告：携带的东西超重。";
    }
    if (weathers.length - aftermath < distToFin) {
        prompt += "<br />警告：挖矿后走到终点超时了。";
    }
    document.querySelector("#costs").innerHTML = "食物: " + totalCost.food + ", 水: " + totalCost.water + prompt;
    document.querySelector("#earnings").innerHTML = "基础价格 " + basePrice + ". 挖矿获得 " + earnings + ", 利润为 " + profit + ", 到达终点钱为 " + (10000 + profit);
}

days.addEventListener("change", (e) => {
    let data = days.value;
    if (isFinite(data)) {
        renderTickboxes(+data);
    }
});
