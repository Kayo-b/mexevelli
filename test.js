// function fact (n) {
//     if (n === 0) {
//         return 0
//     } else {
//         return n * fact(n-1)
//     }  
// } 

// let result = fact(2)
// console.log
function iterator(t) {
    let i = 0;
    function something() { 
            console.log(t[i])
            i = i + 1
            return t[i];
        };
        
    return something() 
} 

const result = iterator([1,2,3,4,5,6])
console.log(result)
