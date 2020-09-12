// Generates hexagonal map pattern 8x8

function line(i, j, k) {
    return i + ";" + j + ";" + k + "\n"; 
}

let str = "";
for (let i = 0; i < 5; i++) {
    for (let j = 0; j < 5; j++) {
        let id = i * 5 + j + 1;
        let k = 0;
        if (id == 18) {
            k = 2;
        }
        if (id == 14) {
            k = 1;
        }
        if (id == 25) {
            k = 3;
        }
        if (j == 0) { // First char
            str += line(id, id, k);
            str += line(id, id + 1, k);
            if (i < 4) {
                str += line(id, id + 5, k);
            }
        } else if (j == 4) { // Last char
            str += line(id, id, k);
            if (i < 4) {
                str += line(id, id + 5, k);
            }
        } else {
            str += line(id, id, k);
            str += line(id, id + 1, k);
            if (i < 4) {
                str += line(id, id + 5, k);
            }
        }
        
    }
}
console.log(str);
