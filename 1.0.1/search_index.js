var documenterSearchIndex = {"docs":
[{"location":"#GPSLC.jl","page":"GPSLC.jl","title":"GPSLC.jl","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"CurrentModule = GPSLC","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Pages=[\"index.md\"]\nDepth = 3","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"gpslc","category":"page"},{"location":"#GPSLC.gpslc","page":"GPSLC.jl","title":"GPSLC.gpslc","text":"gpslc(filename * \".csv\")\ngpslc(DataFrame(X1=...,X2=...,T=...,Y=...,obj=...))\n\nRun posterior inference on the input data.\n\nDatatypes of DataFrame or CSV must follow these standards:\n\nT (Boolean/Float64)\nY (Float64)\nX1...XN (Float64...Float64)\nobj (Any)\n\nOptional parameters\n\nhyperparams::HyperParameters=getHyperParameters(): Hyper parameters primarily define the high level amount of inference to perform.\npriorparams::PriorParameters=getPriorParameters(): Prior parameters define the high level priors to draw from when constructing kernel functions and latent confounder structure.\n\nReturns a GPSLCObject which stores the  hyperparameters, prior parameters, data, and posterior samples.\n\n\n\n\n\n","category":"function"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"The primary struct that we provide interfaces for is the GPSLCObject, which most of the high-level functions like the  treatment effect functions take as input  in addition to their other arguments.","category":"page"},{"location":"#Treatment-Effects","page":"GPSLC.jl","title":"Treatment Effects","text":"","category":"section"},{"location":"#Individual-Treatment-Effect-(ITE)","page":"GPSLC.jl","title":"Individual Treatment Effect (ITE)","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"A contribution of the original GPSLC paper is to produce accurate individual treatment effect conditioned on observed data, using inferred values of latent confounders determined by given structure.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"sampleITE","category":"page"},{"location":"#GPSLC.sampleITE","page":"GPSLC.jl","title":"GPSLC.sampleITE","text":"sampleITE(g, doT)\nsampleITE(g, doT; samplesPerPosterior=10)\n\nEstimate Individual Treatment Effect with GPSLC model\n\nParams:\n\ng::GPSLCObject: Contains data and hyperparameters\ndoT: The requested intervention (e.g. set all treatments to 1.0)\nsamplesPerPosterior: How many ITE samples to draw per posterior sample in g.\n\nReturns:\n\nITEsamples: n x m matrix where n is the number of individuals, and m is the number of samples.\n\n\n\n\n\n","category":"function"},{"location":"#Sample-Average-Treatment-Effect-(SATE)","page":"GPSLC.jl","title":"Sample Average Treatment Effect (SATE)","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Another popular and useful treatment effect estimate is SATE.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"sampleSATE","category":"page"},{"location":"#GPSLC.sampleSATE","page":"GPSLC.jl","title":"GPSLC.sampleSATE","text":"sampleSATE(g, doT)\nsampleSATE(g, doT; samplesPerPosterior=10)\n\nEstimate Sample Average Treatment Effect with GPSLC model\n\nUsing sampleITE, samples can be drawn for the sample average treatment effect\n\nParams:\n\ng::GPSLCObject: Contains data and hyperparameters\ndoT: The requested intervention (e.g. set all treatments to 1.0)\nsamplesPerPosterior: How many samples to draw per posterior sample in g.\n\nReturns:\n\nSATEsamples: n x m matrix where n is the number of individuals, and m is the number of samples.\n\n\n\n\n\n","category":"function"},{"location":"#Counterfactual-Effects","page":"GPSLC.jl","title":"Counterfactual Effects","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"It can be helpful to calculate treatment effect estimates for the whole domain of treatment values in the data, as in the example below. For this we can use predictCounterfactualEffects, which also tracks the values of the doT intervention values for comparison.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"predictCounterfactualEffects","category":"page"},{"location":"#GPSLC.predictCounterfactualEffects","page":"GPSLC.jl","title":"GPSLC.predictCounterfactualEffects","text":"predictCounterfactualOutcomes(g, nSamplesPerMixture)\npredictCounterfactualOutcomes(g, nSamplesPerMixture; fidelity=100)\npredictCounterfactualOutcomes(g, nSamplesPerMixture; fidelity=100, minDoT=0, maxDoT=5)\n\nParams\n\ng::GPSLCObject: The GPSLCObject that inference has already been computed for.\nnSamplesPerMixture::Int64: The number of outcome samples to \n\ndraw from each set of inferred posterior parameters.\n\nfidelity::Int64: How many intervention values to use to cover the domain of treatment values. Higher means more samples.\nminDoT::Float64=min(g.T...): The lowest interventional treatment to use.Defaults to the data g.T's lowest treatment value.\nmaxDoT::Float64=max(g.T...): The highest interventional treatment to use. Defaults to the data g.T's highest treatment value.\n\njulia> ite, doT = predictCounterfactualEffects(g, 30; fidelity=100)\n\nReturns \n\nite::Matrix{Float64}: An array of size [d, n, numPosteriorSamples * nSamplesPerMixture] where d is the number of interventional values defined by fidelity and the range of treatments in g.T - doTrange::Vector{Float64}: The list values of doT used, in order that matches the rows of ite.\n\n\n\n\n\n","category":"function"},{"location":"#Summarizing","page":"GPSLC.jl","title":"Summarizing","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"It can be helpful to summarize the inferred individual treatment effects and sample average treatment effects into mean and credible intervals.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"summarizeEstimates","category":"page"},{"location":"#GPSLC.summarizeEstimates","page":"GPSLC.jl","title":"GPSLC.summarizeEstimates","text":"summarizeEstimates(samples)\nsummarizeEstimates(samples; savetofile=\"ite_samples.csv\")\n\nSummarize Predicted Estimates (Counterfactual Outcomes or Individual Treatment Effects)\n\nCreate dataframe of mean, lower and upper quantiles of the samples from sampleITE or predictCounterfactualEffects.\n\nParams:\n\nsamples: n x m array of samples\nsavetofile: Optionally save the resultant dataframe as CSV to the filename passed.\n\nReturns:\n\ndf: Dataframe of Individual, Mean, LowerBound, and UpperBound values for the credible intervals around the sample.\n\n\n\n\n\n","category":"function"},{"location":"#Examples","page":"GPSLC.jl","title":"Examples","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"The example below is similar to Figure 3 in the original GPSLC paper. ","category":"page"},{"location":"#New-England-Energy-Consumption","page":"GPSLC.jl","title":"New England Energy Consumption","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"This example creates an example plot of the NEEC treatment vs outcome data. Plots the original and the intervened data together.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"import Random # hide\nRandom.seed!(1234) # hide\nusing GPSLC # hide\nusing Plots # hide\nusing Statistics # hide\n\n# run inference\ndataFile = \"../example_data/NEEC_sampled.csv\"\ng = gpslc(dataFile)\n\n# collect counterfactual outcomes\nidx = vec(g.obj .== \"MA\")\n\nite, doT = predictCounterfactualEffects(g, 30)\nYcf = mean(g.Y[idx]) .+ ite[:, idx, :]\n\n# get credible interval on counterfactual outcomes\nsate = mean(Ycf, dims=2)[:, 1, :]\ninterval = summarizeEstimates(sate)\n\n# plot outcomes and credible interval\ntreatmentScale = 100\noutcomeScale = 10\n\n# observed data\nplot(legend=:outertopright, size=(750, 400))\nT = g.T[idx] .* treatmentScale\nY = g.Y[idx] .* outcomeScale\nscatter!(T, Y, label=\"MA obs\", markershape=:circle)\n\n# counterfactual\nT = doT .* treatmentScale\nY = interval[!, \"Mean\"] .* outcomeScale\nplot!(T, Y, label=\"MA cf\", color=:green,\n    ribbon=(interval[!, \"LowerBound\"], interval[!, \"UpperBound\"]))\n\nxlabel!(\"Temperature °F\")\nylabel!(\"Energy Consumption (GWh)\")\ntitle!(\"Energy Consumption for Massachusetts\")","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Above we can see the Gaussian Process using individual treatment effect estimates to predict the energy consumption (outcome) from the temperature (treatment) for Massachusetts. The shaded region is a 90% credible interval from the samples taken by predictCounterfactualEffects and processed by summarizeEstimates which calculates the credible intervals by computing the 5th and 95th percentiles of the samples.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"The data can be found here.","category":"page"},{"location":"#Types","page":"GPSLC.jl","title":"Types","text":"","category":"section"},{"location":"#External-Types","page":"GPSLC.jl","title":"External Types","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Relevant types for using GPSLC.jl in a high-level way, where  inference and prediction are automatically performed are described below.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"HyperParameters","category":"page"},{"location":"#GPSLC.HyperParameters","page":"GPSLC.jl","title":"GPSLC.HyperParameters","text":"HyperParameters\n\nDefine the high-level attributes of the inference procedure. More information on each of the attributes can be found in getHyperParameters.\n\n\n\n\n\n","category":"type"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"The default values for HyperParameters are provided by","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"getHyperParameters","category":"page"},{"location":"#GPSLC.getHyperParameters","page":"GPSLC.jl","title":"GPSLC.getHyperParameters","text":"getHyperParameters()\n\nReturns default values for hyperparameters\n\nnU = 1: Number of latent confounding variables assumed to be influencing all the instances that belong to one object. Inference will be performed over these values.\nnOuter = 20: Number of posterior samples to draw.\nnMHInner = 5: Number of internal Metropolis-Hastings updates to make per posterior sample.\nnESInner = 5: Number of elliptical-slice sampling updates to make per posterior for latent confounders and binary treatment.\nnBurnIn = 5: Number of posterior samples to discard when making predictions and estimates.\nstepSize = 1: How frequently to use posterior samples (1 being every one after burnIn, higher being every stepSizeth).\npredictionCovarianceNoise=1e-10: Predicting with Gaussian processes requires use of covariance matrices that are Symmetric Positive Definite, and this covariance noise on the diagonal ensures these operations can be performed in a stable and consistent way.\n\n\n\n\n\n","category":"function"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"PriorParameters","category":"page"},{"location":"#GPSLC.PriorParameters","page":"GPSLC.jl","title":"GPSLC.PriorParameters","text":"PriorParameters\n\nContains shapes and scales for various Inverse Gamma distributions used as priors for kernel parameters and other parameters. More information on each of the attributes can be found in getPriorParameters.\n\n\n\n\n\n","category":"type"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"The default values for PriorParameters are provided by","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"getPriorParameters","category":"page"},{"location":"#GPSLC.getPriorParameters","page":"GPSLC.jl","title":"GPSLC.getPriorParameters","text":"getPriorParameters()\n\nThese are standard values for scale and shape of Inverse Gamma priors over kernel parameters, confounder structure covariance noise, and confounder Gaussian prior covariance. \n\nuNoiseShape::Float64=4.0: shape of the InvGamma prior over the noise of U\nuNoiseScale::Float64=4.0: scale of the InvGamma prior over the noise of U\nxNoiseShape::Float64=4.0: shape of the InvGamma prior over the noise of X\nxNoiseScale::Float64=4.0: scale of the InvGamma prior over the noise of X\ntNoiseShape::Float64=4.0: shape of the InvGamma prior over the noise of T\ntNoiseScale::Float64=4.0: scale of the InvGamma prior over the noise of T\nyNoiseShape::Float64=4.0: shape of the InvGamma prior over the noise of Y\nyNoiseScale::Float64=4.0: scale of the InvGamma prior over the noise of Y\nxScaleShape::Float64=4.0: shape of the InvGamma prior over kernel scale of X\nxScaleScale::Float64=4.0: scale of the InvGamma prior over kernel scale of X\ntScaleShape::Float64=4.0: shape of the InvGamma prior over kernel scale of T\ntScaleScale::Float64=4.0: scale of the InvGamma prior over kernel scale of T\nyScaleShape::Float64=4.0: shape of the InvGamma prior over kernel scale of Y\nyScaleScale::Float64=4.0: scale of the InvGamma prior over kernel scale of Y\nuxLSShape::Float64=4.0: shape of the InvGamma prior over kernel lengthscale of U and X\nuxLSScale::Float64=4.0: scale of the InvGamma prior over kernel lengthscale of U and X\nutLSShape::Float64=4.0: shape of the InvGamma prior over kernel lengthscale of U and T\nutLSScale::Float64=4.0: scale of the InvGamma prior over kernel lengthscale of U and T\nxtLSShape::Float64=4.0: shape of the InvGamma prior over kernel lengthscale of X and T\nxtLSScale::Float64=4.0: scale of the InvGamma prior over kernel lengthscale of X and T\nuyLSShape::Float64=4.0: shape of the InvGamma prior over kernel lengthscale of U and Y\nuyLSScale::Float64=4.0: scale of the InvGamma prior over kernel lengthscale of U and Y\nxyLSShape::Float64=4.0: shape of the InvGamma prior over kernel lengthscale of X and Y\nxyLSScale::Float64=4.0: scale of the InvGamma prior over kernel lengthscale of X and Y\ntyLSShape::Float64=4.0: shape of the InvGamma prior over kernel lengthscale of T and Y\ntyLSScale::Float64=4.0: scale of the InvGamma prior over kernel lengthscale of T and Y\nsigmaUNoise::Float64=1.0e-13: noise added to matrix to make covariance stable and invertible\nsigmaUCov::Float64=1.0: assumed covariance over structured confounders\ndrift::Float64=0.5: as in the paper, Metropolis Hastings Gaussian Drift\n\n\n\n\n\n","category":"function"},{"location":"#GPSLCObject","page":"GPSLC.jl","title":"GPSLCObject","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"GPSLCObject","category":"page"},{"location":"#GPSLC.GPSLCObject","page":"GPSLC.jl","title":"GPSLC.GPSLCObject","text":"GPSLCObject\n\nThis is the struct in GPSLC.jl that contains the data, hyperparamters, prior parameters, and posterior samples. It provides the primary interfaces to abstract the internals of GPSLC away from the higher-order functions like sampleITE and sampleSATE.\n\nReturned by gpslc\n\n\n\n\n\n","category":"type"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Helpful functions for retrieving meta values from a GPSLCObject","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"getN","category":"page"},{"location":"#GPSLC.getN","page":"GPSLC.jl","title":"GPSLC.getN","text":"getN(g)\n\nNumber of individuals.\n\n\n\n\n\n","category":"function"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"getNX","category":"page"},{"location":"#GPSLC.getNX","page":"GPSLC.jl","title":"GPSLC.getNX","text":"getNX(g)\n\nNumber of covariates (and observed confounders).\n\n\n\n\n\n","category":"function"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"getNU","category":"page"},{"location":"#GPSLC.getNU","page":"GPSLC.jl","title":"GPSLC.getNU","text":"getNU(g)\n\nNumber of latent confounders to perform inference over.\n\n\n\n\n\n","category":"function"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"getNumPosteriorSamples","category":"page"},{"location":"#GPSLC.getNumPosteriorSamples","page":"GPSLC.jl","title":"GPSLC.getNumPosteriorSamples","text":"getNumPosteriorSamples(g)\n\nNumber of posterior samples that will be used based on hyperparameters.\n\n\n\n\n\n","category":"function"},{"location":"#Internal-Types","page":"GPSLC.jl","title":"Internal Types","text":"","category":"section"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"These types are are used in internal inference procedures, so if you need to fine tune the inference, or access the posterior functions directly, these will be relevant to your work.","category":"page"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Confounders","category":"page"},{"location":"#GPSLC.Confounders","page":"GPSLC.jl","title":"GPSLC.Confounders","text":"Confounders (U)\n\nLatent confounders that GPSLC performs inference over.\n\nEither 1D or 2D matrices of Float64 values.\n\n\n\n\n\n","category":"type"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Covariates","category":"page"},{"location":"#GPSLC.Covariates","page":"GPSLC.jl","title":"GPSLC.Covariates","text":"Covariates (X) Observed confounders and covariates.\n\nMatrix{Float64} is the only valid structure for covariates\n\n\n\n\n\n","category":"type"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Treatment","category":"page"},{"location":"#GPSLC.Treatment","page":"GPSLC.jl","title":"GPSLC.Treatment","text":"Treatment (T)\n\nIs made up of BinaryTreatment which is an alias for Vector{Bool} and ContinuousTreatment which is an alias for Vector{Float64}. These types support other vector types to afford compatibility with internal libraries.\n\n\n\n\n\n","category":"type"},{"location":"","page":"GPSLC.jl","title":"GPSLC.jl","text":"Outcome","category":"page"},{"location":"#GPSLC.Outcome","page":"GPSLC.jl","title":"GPSLC.Outcome","text":"Outcome (Y)\n\nThe outcome for the series of Gaussian Process predictions is a Vector{Float64}. Currently only continuous values are supported as outcomes for input data.\n\n\n\n\n\n","category":"type"}]
}