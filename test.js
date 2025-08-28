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

// function() {
//     console.log('a')
// }


// function test() {
//     console.log('test')
// } 
// test()


// function test2(t) {
//     let i = -1;
//     return function () {
//         i = i + 1;
//         return t[i];
//     }
// }
// const array = ['a','b','c','d']
// const iterator = test2(array)
// console.log(iterator())
// console.log(iterator())
// console.log(iterator())