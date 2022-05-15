var documenterSearchIndex = {"docs":
[{"location":"conditionalITE/#Conditional-Individual-Treatment-Effect","page":"Conditional Individual Treatment Effect","title":"Conditional Individual Treatment Effect","text":"","category":"section"},{"location":"conditionalITE/","page":"Conditional Individual Treatment Effect","title":"Conditional Individual Treatment Effect","text":"A contribution of the original GPSLC paper is to produce accurate individual treatment effect conditioned on covariates, using inferred values of latent confounders determined by given structure.","category":"page"},{"location":"examples/#Examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/#Simple-example","page":"Examples","title":"Simple example","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The file examples/basicExample.jl has a simple use case for getting  individual treatment effect samples","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"julia> dataFile = \"examples/data/NEEC_sampled.csv\"\njulia> g = gpslc(dataFile)\njulia> ITEsamples = sampleITE(g, doT=0.6)\njulia> summarizeITE(ITEsamples)","category":"page"},{"location":"examples/#Command-Line-Tool","page":"Examples","title":"Command Line Tool","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"These examples demonstrate the capabilities of GPSLC via a commandline tool submitted with the original ICML 2020 paper.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"By default, julia examples/estimateITE.jl uses the biased New England Energy Consumption data found in data/NEEC_samples.csv and an intervention assignment of 80 degrees Fahrenheit, saving the results in \"results/NEECsampled80.csv\". The dataset, output filepath, intervention assignment, and inference hyperparameters can all be specified as command line arguments. For example,   ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"julia examples/estimateITE.jl --doT 0.0 --output_filepath examples/results/NEEC_samples_0.csv","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"runs the inference with an intervention assignment of 0 degrees Farenheit. For a full set of available command line arguments, run julia examples/estimateITE.jl --help in the command line. Note: The default number of inference steps is lower than shown in the paper results.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"To run this script on external data, please follow the format in any of the sample data files in the data folder. Specifically, the csv file should include a column labeled \"T\", a column labeled \"Y\", any number of covariates, followed by a column labeled \"obj\". This implementation assumes that the instances are grouped together in the input data csv file.","category":"page"},{"location":"#GPSLC.jl-Documentation","page":"GPSLC.jl Documentation","title":"GPSLC.jl Documentation","text":"","category":"section"},{"location":"","page":"GPSLC.jl Documentation","title":"GPSLC.jl Documentation","text":"CurrentModule = GPSLC","category":"page"},{"location":"","page":"GPSLC.jl Documentation","title":"GPSLC.jl Documentation","text":"gpslc","category":"page"},{"location":"#GPSLC.gpslc","page":"GPSLC.jl Documentation","title":"GPSLC.gpslc","text":"gpslc\n\nRun posterior inference on the input data.\n\nDatatypes of DataFrame or CSV must follow these standards:\n\nT (Boolean/Float64)\nY (Float64)\nX1...XN (Float64...Float64)\nobj (Any)\n\nReturns a GPSLCObject which stores the  hyperparameters, priorparameters, data, and posterior samples.\n\n\n\n\n\n","category":"function"}]
}
