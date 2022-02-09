using Pkg
Pkg.activate(".")

using Random
Random.seed!(1234)

using GPSLC

function main()
    X, T, Y, SigmaU = prepareData("examples/data/NEEC_sampled.csv")

    println("Running Inference on U and Kernel Hyperparameters")
    posteriorsample = samplePosterior(X, T, Y, SigmaU)

    println("Estimating ITE")
    ITEsamples = sampleITE(X, T, Y, SigmaU; posteriorsample = posteriorsample)

    summarizeITE(ITEsamples; savetofile = "examples/results/NEEC_sampled_80.csv")
end

main()
