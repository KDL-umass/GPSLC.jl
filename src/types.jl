export GPSLCObject, getN, getNU, getNX,
    HyperParameters,
    PriorParameters,
    UStructure,
    Confounders,
    Covariates,
    Treatment,
    Outcome,
    SupportedRBFVector,
    SupportedRBFData,
    SupportedRBFMatrix,
    SupportedRBFLengthscale,
    SupportedCovarianceMatrix,
    XScaleOrNoise,
    ReshapeableMatrix

"""
    HyperParameters
Controls the high-level attributes of the inference procedure.
"""
mutable struct HyperParameters
    nU::Int64
    nOuter::Int64
    nMHInner::Int64
    nESInner::Int64
    nBurnIn::Int64
    stepSize::Int64
end

"""
    PriorParameters

Contains shapes and scales for various Inverse Gamma distributions
used as priors for kernel parameters and other parameters.
"""
PriorParameters = Dict{String,Any}

"""SigmaU structured prior for U"""
UStructure = Matrix{Float64}

"""Confounder (U)"""
Confounders = Union{
    Array{Array{Float64,1}},
    Array{Vector{Float64}},
    Vector{Vector{Float64}},
    Array{Float64,2},
    Matrix{Float64},
    Vector{Float64},
    FunctionalCollections.PersistentVector{Vector{Float64}},
    FunctionalCollections.PersistentVector{Float64},
}


"""Covariates (X)"""
Covariates = Union{
    Array{Array{Float64,1}},
    Array{Vector{Float64}},
    Vector{Vector{Float64}},
    Array{Float64,2},
    Matrix{Float64},
}

"""Binary Treatment (T)"""
BinaryTreatment = Union{
    Vector{Bool},
    FunctionalCollections.PersistentVector{Bool},
}

"""Continuous Treatment (T)"""
ContinuousTreatment = Union{
    Vector{Float64},
    FunctionalCollections.PersistentVector{Float64},
}

"""Treatment (T)"""
Treatment = Union{
    BinaryTreatment,
    ContinuousTreatment
}

"""Outcome (Y)"""
Outcome = Union{
    Vector{Float64},
}

"""Intervention (doT)"""
Intervention = Union{
    Bool,
    Vector{Bool},
    Float64,
    Vector{Float64},
}


"""Viable inputs to the rbfKernelLog function in linear algebra datatypes"""
SupportedRBFVector = Union{
    FunctionalCollections.PersistentVector{Float64},
    FunctionalCollections.PersistentVector{Bool},
    Array{Float64,1},
    Vector{Int64},
    Vector{Bool},
    Vector{Float64},
    Array{Int64,1},
    Array{Bool,1},
}

"""Viable inputs to the rbfKernelLog function that are nested lists"""
SupportedRBFData = Union{
    FunctionalCollections.PersistentVector{Vector{Float64}},
    FunctionalCollections.PersistentVector{Vector{Int64}},
    FunctionalCollections.PersistentVector{Vector{Bool}},
    Vector{Vector{Float64}},
    Vector{Vector{Int64}},
    Vector{Vector{Bool}},
    Array{Vector{Float64},1},
    Array{Vector{Int64},1},
    Array{Vector{Bool},1}
}

"""Viable inputs to the rbfKernelLog function in linear algebra datatypes"""
SupportedRBFMatrix = Union{
    Matrix{Float64},
    Matrix{Int64},
    Matrix{Bool},
    Vector{Float64},
    Vector{Int64},
    Vector{Bool},
    FunctionalCollections.PersistentVector{Float64},
    FunctionalCollections.PersistentVector{Int64},
    FunctionalCollections.PersistentVector{Bool},
}

"""Viable inputs to the rbfKernelLog function as kernel lengthscales"""
SupportedRBFLengthscale = Union{
    Int64,
    Matrix{Int64},
    Vector{Int64},
    Array{Int64,1},
    FunctionalCollections.PersistentVector{Int64},
    Float64,
    Matrix{Float64},
    Vector{Float64},
    Array{Float64,1},
    FunctionalCollections.PersistentVector{Float64},
}

"""Viable inputs to the processCov function"""
SupportedCovarianceMatrix = Union{
    Vector{Matrix{Float64}},
}

XScaleOrNoise = Union{
    Vector{Vector{Float64}},
    FunctionalCollections.PersistentVector{Float64},
}

"""Matrix that can be reshaped"""
ReshapeableMatrix = Union{
    Matrix{Bool},
    Matrix{Int64},
    Matrix{Float64},
    Vector{Vector{Bool}},
    Vector{Vector{Int64}},
    Vector{Vector{Float64}},
    FunctionalCollections.PersistentVector{Vector{Bool}},
    FunctionalCollections.PersistentVector{Vector{Int64}},
    FunctionalCollections.PersistentVector{Vector{Float64}},
    FunctionalCollections.PersistentVector{FunctionalCollections.PersistentVector{Bool}},
    FunctionalCollections.PersistentVector{FunctionalCollections.PersistentVector{Int64}},
    FunctionalCollections.PersistentVector{FunctionalCollections.PersistentVector{Float64}},
}

"""
    GPSLCObject

A type that contains the data and posterior samples

Returned by [`gpslc`](@ref)

"""
struct GPSLCObject
    hyperparams::HyperParameters
    priorparams::PriorParameters
    SigmaU::UStructure
    X::Union{Covariates,Nothing}
    T::Treatment
    Y::Outcome
    posteriorSamples::Vector{Any}
end

"""Constructor for GPSLCObject before sampling from posterior."""
function GPSLCObject(hyperparams::HyperParameters, priorparams::PriorParameters, SigmaU::UStructure, X::Union{Covariates,Nothing}, T::Treatment, Y::Outcome)
    posteriorSamples = samplePosterior(hyperparams, priorparams, SigmaU, X, T, Y)
    GPSLCObject(hyperparams, priorparams, SigmaU, X, T, Y, posteriorSamples)
end


"""Number of individuals."""
function getN(g::GPSLCObject)
    size(g.Y, 1)
end

"""Number of covariates (and observed confounders)."""
function getNX(g::GPSLCObject)
    if ndims(g.X) == 2
        return size(g.X, 2)
    end
    return 1
end

"""Number of latent confounders to perform inference over."""
function getNU(g::GPSLCObject)
    g.hyperparams.nU
end