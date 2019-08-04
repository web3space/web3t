require! {
    \./pow-verify.js
    \./pow-solve.js
    \./pow-gen.js
}

task = pow-gen 19

err, solution <- pow-solve task
console.log err, solution

err, res <- pow-verify { solution, ...task }
console.log err, res