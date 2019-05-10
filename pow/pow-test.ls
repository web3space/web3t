require! {
    \./pow-verify.ls
    \./pow-solve.ls
    \./pow-gen.ls
}

task = pow-gen 19

err, solution <- pow-solve task
console.log err, solution

err, res <- pow-verify { solution, ...task }
console.log err, res