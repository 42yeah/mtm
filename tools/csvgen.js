// Generates hexagonal map pattern 8x8

function line(i, j, k) {
    return i + ";" + j + ";" + k + "\n"; 
}

let str = "";
for (let i = 0; i < 8; i++) {
    for (let j = 0; j < 8; j++) {
        let id = i * 8 + j + 1;
        let k = 0;
        if (id == 30 || id == 55) {
            k = 2;
        }
        if (id == 62 || id == 39) {
            k = 1;
        }
        if (id == 64) {
            k = 3;
        }
        switch (i % 2) {
            case 0:
                if (j == 0) { // First char
                    str += line(id, id, k);
                    str += line(id, id + 1, k);
                    if (i < 7) {
                        str += line(id, id + 8, k);
                    }
                } else if (j == 7) { // Last char
                    str += line(id, id, k);
                    if (i < 7) {
                        str += line(id, id + 7, k);
                        str += line(id, id + 8, k);
                    }
                } else {
                    str += line(id, id, k);
                    str += line(id, id + 1, k);
                    if (i < 7) {
                        str += line(id, id + 8, k);
                        str += line(id, id + 7, k);
                    }
                }
                break;

            case 1:
                if (j == 0) {
                    str += line(id, id, k);
                    str += line(id, id + 1, k);
                    if (i < 7) {
                        str += line(id, id + 8, k);
                        str += line(id, id + 9, k);
                    }
                } else if (j == 7) {
                    str += line(id, id, k);
                    if (i < 7) {
                        str += line(id, id + 8, k);
                    }
                } else {
                    str += line(id, id, k);
                    str += line(id, id + 1, k);
                    if (i < 7) {
                        str += line(id, id + 8, k);
                        str += line(id, id + 9, k);
                    }
                }
                break;
        }
        
    }
}
console.log(str);
