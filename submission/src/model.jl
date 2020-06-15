module Model

using Gen
using LinearAlgebra
import Base.show
import FunctionalCollections

export processCov, rbfKernelLog, 
       ContinuousGPSLC, NoCovContinuousGPSLC, NoUContinuousGPSLC, NoCovNoUContinuousGPSLC,
       BinaryGPSLC, NoCovBinaryGPSLC, NoUBinaryGPSLC, NoCovNoUBinaryGPSLC

function rbfKernelLog(X1::Array{Float64, 1}, X2::Array{Float64, 1}, LS::Array{Float64, 1})
    return -broadcast(/, ((X1 .- X2').^2,), LS.^2)
end

function rbfKernelLog(X1::Array{Float64, 1}, X2::Array{Float64, 1}, 
                      LS::FunctionalCollections.PersistentVector{Float64})
    return -broadcast(/, ((X1 .- X2').^2,), LS.^2)
end

function rbfKernelLog(X1::Array{Float64, 1}, X2::Array{Float64, 1}, LS::Float64)
    return -((X1 .- X2')/LS).^2
end

function rbfKernelLog(X1::Array{Bool, 1}, X2::Array{Bool, 1}, LS::Float64)
    return -((X1 .- X2')/LS).^2
end

function rbfKernelLog(X1::FunctionalCollections.PersistentVector{Bool}, 
                      X2::FunctionalCollections.PersistentVector{Bool}, LS::Float64)
    return -((X1 .- X2')/LS).^2
end


expit(x::Real) = exp(x) / (1.0 + exp(x))

function processCov(logCov::Array{Float64}, scale::Float64, noise::Float64)
    return exp.(logCov) * scale + 1I*noise
end

function processCov(logCov::Array{Float64}, scale::Float64, noise::Nothing)
    return exp.(logCov) * scale
end

@gen (static) function generateLS(shape, scale)
    LS = @trace(inv_gamma(shape, scale), :LS)
    return LS
end

@gen (static) function generateScale(shape, scale)
    Scale = @trace(inv_gamma(shape, scale), :Scale)
    return Scale
end

@gen (static) function generateNoise(shape, scale)
    Noise = @trace(inv_gamma(shape, scale), :Noise)
    return Noise
end

@gen (static) function generateBinaryT(logitT)
    T = @trace(bernoulli(expit(logitT)), :T)
    return T
end

@gen (static) function generateU(Ucov::Array{Float64}, n::Int)
    U = @trace(mvnormal(fill(0, n), Ucov), :U)
    return U
end

@gen (static) function generateX(Xcov::Array{Float64}, n::Int)
    X = @trace(mvnormal(fill(0, n), Xcov), :X)
    return X
end
    
MappedGenerateLS = Map(generateLS)
MappedMappedGenerateLS = Map(MappedGenerateLS)
MappedGenerateScale = Map(generateScale)
MappedGenerateBinaryT = Map(generateBinaryT)
MappedGenerateNoise = Map(generateNoise)
MappedGenerateU = Map(generateU)
MappedGenerateX = Map(generateX)

load_generated_functions()

@gen (static) function ContinuousGPSLC(hyperparams, nX, nU)
    n = size(hyperparams["SigmaU"])[1]
    
#   Prior over Noise
    uNoise = @trace(inv_gamma(hyperparams["uNoiseShape"], hyperparams["uNoiseScale"]), :uNoise)
    tNoise = @trace(inv_gamma(hyperparams["tNoiseShape"], hyperparams["tNoiseScale"]), :tNoise)
    xNoise = @trace(MappedGenerateNoise(fill(hyperparams["xNoiseShape"], nX),
                                        fill(hyperparams["xNoiseScale"], nX)), :xNoise)
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    utLS = @trace(MappedGenerateLS(fill(hyperparams["utLSShape"], nU), 
                                   fill(hyperparams["utLSScale"], nU)), :utLS)
    uyLS = @trace(MappedGenerateLS(fill(hyperparams["uyLSShape"], nU), 
                                   fill(hyperparams["uyLSScale"], nU)), :uyLS)
    uxLS = @trace(MappedMappedGenerateLS(fill(fill(hyperparams["uxLSShape"], nX), nU), 
                                         fill(fill(hyperparams["uxLSScale"], nX), nU)), :uxLS)
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    xtLS = @trace(MappedGenerateLS(fill(hyperparams["xtLSShape"], nX), 
                                   fill(hyperparams["xtLSScale"], nX)), :xtLS)
    xyLS = @trace(MappedGenerateLS(fill(hyperparams["xyLSShape"], nX), 
                                   fill(hyperparams["xyLSScale"], nX)), :xyLS)
    
#   Prior over Kernel Scale
    xScale = @trace(MappedGenerateScale(fill(hyperparams["xScaleShape"], nX),
                                        fill(hyperparams["xScaleScale"], nX)), :xScale)
    tScale = @trace(inv_gamma(hyperparams["tScaleShape"], hyperparams["tScaleScale"]), :tScale)
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data 
    uCov = hyperparams["SigmaU"] * uNoise
    U = @trace(MappedGenerateU(fill(uCov, nU), fill(n, nU)), :U)
    Xcov = broadcast(processCov, sum(broadcast(rbfKernelLog, U, U, uxLS)), xScale, xNoise)

    X = @trace(MappedGenerateX(Xcov, fill(n, nX)), :X)
    
    utCovLog = sum(broadcast(rbfKernelLog, U, U, utLS))
    xtCovLog = sum(broadcast(rbfKernelLog, X, X, xtLS))
    Tcov = processCov(utCovLog + xtCovLog, tScale, tNoise)
    T = @trace(mvnormal(fill(0, n), Tcov), :T)
    
    uyCovLog = sum(broadcast(rbfKernelLog, U, U, uyLS))
    xyCovLog = sum(broadcast(rbfKernelLog, X, X, xyLS))
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(uyCovLog + xyCovLog + tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end

# Covariates omitted.
@gen (static) function NoCovContinuousGPSLC(hyperparams, nU)
    n = size(hyperparams["SigmaU"])[1]
    
#   Prior over Noise
    uNoise = @trace(inv_gamma(hyperparams["uNoiseShape"], hyperparams["uNoiseScale"]), :uNoise)
    tNoise = @trace(inv_gamma(hyperparams["tNoiseShape"], hyperparams["tNoiseScale"]), :tNoise)
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    utLS = @trace(MappedGenerateLS(fill(hyperparams["utLSShape"], nU), 
                                   fill(hyperparams["utLSScale"], nU)), :utLS)
    uyLS = @trace(MappedGenerateLS(fill(hyperparams["uyLSShape"], nU), 
                                   fill(hyperparams["uyLSScale"], nU)), :uyLS)
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    
#   Prior over Kernel Scale
    tScale = @trace(inv_gamma(hyperparams["tScaleShape"], hyperparams["tScaleScale"]), :tScale)
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data 
    uCov = hyperparams["SigmaU"] * uNoise
    U = @trace(MappedGenerateU(fill(uCov, nU), fill(n, nU)), :U)
    
    utCovLog = sum(broadcast(rbfKernelLog, U, U, utLS))
    Tcov = processCov(utCovLog, tScale, tNoise)
    T = @trace(mvnormal(fill(0, n), Tcov), :T)
    
    uyCovLog = sum(broadcast(rbfKernelLog, U, U, uyLS))
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(uyCovLog + tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end

@gen (static) function NoUContinuousGPSLC(hyperparams, X)
    n = length(X[1])
    nX = length(X)
    
#   Prior over Noise
    tNoise = @trace(inv_gamma(hyperparams["tNoiseShape"], hyperparams["tNoiseScale"]), :tNoise)
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    xtLS = @trace(MappedGenerateLS(fill(hyperparams["xtLSShape"], nX), 
                                   fill(hyperparams["xtLSScale"], nX)), :xtLS)
    xyLS = @trace(MappedGenerateLS(fill(hyperparams["xyLSShape"], nX), 
                                   fill(hyperparams["xyLSScale"], nX)), :xyLS)
    
#   Prior over Kernel Scale
    tScale = @trace(inv_gamma(hyperparams["tScaleShape"], hyperparams["tScaleScale"]), :tScale)
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data 
    xtCovLog = sum(broadcast(rbfKernelLog, X, X, xtLS))
    Tcov = processCov(xtCovLog, tScale, tNoise)
    T = @trace(mvnormal(fill(0, n), Tcov), :T)
    
    xyCovLog = sum(broadcast(rbfKernelLog, X, X, xyLS))
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(xyCovLog + tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end

# Covariates and U omitted.
@gen (static) function NoCovNoUContinuousGPSLC(hyperparams, T)
    n = length(T)
    
#   Prior over Noise
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    
#   Prior over Kernel Scale
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data     
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end
# + {}
@gen (static) function BinaryGPSLC(hyperparams, nX, nU)
    n = size(hyperparams["SigmaU"])[1]
    
#   Prior over Noise
    uNoise = @trace(inv_gamma(hyperparams["uNoiseShape"], hyperparams["uNoiseScale"]), :uNoise)
    tNoise = @trace(inv_gamma(hyperparams["tNoiseShape"], hyperparams["tNoiseScale"]), :tNoise)
    xNoise = @trace(MappedGenerateNoise(fill(hyperparams["xNoiseShape"], nX),
                                        fill(hyperparams["xNoiseScale"], nX)), :xNoise)
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    utLS = @trace(MappedGenerateLS(fill(hyperparams["utLSShape"], nU), 
                                   fill(hyperparams["utLSScale"], nU)), :utLS)
    uyLS = @trace(MappedGenerateLS(fill(hyperparams["uyLSShape"], nU), 
                                   fill(hyperparams["uyLSScale"], nU)), :uyLS)
    uxLS = @trace(MappedMappedGenerateLS(fill(fill(hyperparams["uxLSShape"], nX), nU), 
                                         fill(fill(hyperparams["uxLSScale"], nX), nU)), :uxLS)
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    xtLS = @trace(MappedGenerateLS(fill(hyperparams["xtLSShape"], nX), 
                                   fill(hyperparams["xtLSScale"], nX)), :xtLS)
    xyLS = @trace(MappedGenerateLS(fill(hyperparams["xyLSShape"], nX), 
                                   fill(hyperparams["xyLSScale"], nX)), :xyLS)
    
#   Prior over Kernel Scale
    xScale = @trace(MappedGenerateScale(fill(hyperparams["xScaleShape"], nX),
                                        fill(hyperparams["xScaleScale"], nX)), :xScale)
    tScale = @trace(inv_gamma(hyperparams["tScaleShape"], hyperparams["tScaleScale"]), :tScale)
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data 
    uCov = hyperparams["SigmaU"] * uNoise
    U = @trace(MappedGenerateU(fill(uCov, nU), fill(n, nU)), :U)
    Xcov = broadcast(processCov, sum(broadcast(rbfKernelLog, U, U, uxLS)), xScale, xNoise)

    X = @trace(MappedGenerateX(Xcov, fill(n, nX)), :X)
    
    utCovLog = sum(broadcast(rbfKernelLog, U, U, utLS))
    xtCovLog = sum(broadcast(rbfKernelLog, X, X, xtLS))
    logitTcov = processCov(utCovLog + xtCovLog, tScale, tNoise)
    logitT = @trace(mvnormal(fill(0, n), logitTcov), :logitT)
    T = @trace(MappedGenerateBinaryT(logitT), :T)
    
    uyCovLog = sum(broadcast(rbfKernelLog, U, U, uyLS))
    xyCovLog = sum(broadcast(rbfKernelLog, X, X, xyLS))
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(uyCovLog + xyCovLog + tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end

@gen (static) function NoCovBinaryGPSLC(hyperparams, nU)
    n = size(hyperparams["SigmaU"])[1]
    
#   Prior over Noise
    uNoise = @trace(inv_gamma(hyperparams["uNoiseShape"], hyperparams["uNoiseScale"]), :uNoise)
    tNoise = @trace(inv_gamma(hyperparams["tNoiseShape"], hyperparams["tNoiseScale"]), :tNoise)
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    utLS = @trace(MappedGenerateLS(fill(hyperparams["utLSShape"], nU), 
                                   fill(hyperparams["utLSScale"], nU)), :utLS)
    uyLS = @trace(MappedGenerateLS(fill(hyperparams["uyLSShape"], nU), 
                                   fill(hyperparams["uyLSScale"], nU)), :uyLS)
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    
#   Prior over Kernel Scale
    tScale = @trace(inv_gamma(hyperparams["tScaleShape"], hyperparams["tScaleScale"]), :tScale)
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data 
    uCov = hyperparams["SigmaU"] * uNoise
    U = @trace(MappedGenerateU(fill(uCov, nU), fill(n, nU)), :U)
    
    utCovLog = sum(broadcast(rbfKernelLog, U, U, utLS))
    logitTcov = processCov(utCovLog, tScale, tNoise)
    logitT = @trace(mvnormal(fill(0, n), logitTcov), :logitT)
    T = @trace(MappedGenerateBinaryT(logitT), :T)
    
    uyCovLog = sum(broadcast(rbfKernelLog, U, U, uyLS))
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(uyCovLog + tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end

@gen (static) function NoUBinaryGPSLC(hyperparams, X)
    n = size(X[1])
    nX = size(X)
    
#   Prior over Noise
    tNoise = @trace(inv_gamma(hyperparams["tNoiseShape"], hyperparams["tNoiseScale"]), :tNoise)
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    xtLS = @trace(MappedGenerateLS(fill(hyperparams["xtLSShape"], nX), 
                                   fill(hyperparams["xtLSScale"], nX)), :xtLS)
    xyLS = @trace(MappedGenerateLS(fill(hyperparams["xyLSShape"], nX), 
                                   fill(hyperparams["xyLSScale"], nX)), :xyLS)
    
#   Prior over Kernel Scale
    tScale = @trace(inv_gamma(hyperparams["tScaleShape"], hyperparams["tScaleScale"]), :tScale)
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data 
    xtCovLog = sum(broadcast(rbfKernelLog, X, X, xtLS))
    logitTcov = processCov(xtCovLog, tScale, tNoise)
    logitT = @trace(mvnormal(fill(0, n), logitTcov), :logitT)
    T = @trace(MappedGenerateBinaryT(logitT), :T)
    
    xyCovLog = sum(broadcast(rbfKernelLog, X, X, xyLS))
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(xyCovLog + tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end

@gen (static) function NoCovNoUBinaryGPSLC(hyperparams, T)
    n = size(T)
    
#   Prior over Noise
    yNoise = @trace(inv_gamma(hyperparams["yNoiseShape"], hyperparams["yNoiseScale"]), :yNoise)
    
#   Prior over Kernel Lengthscales
    tyLS = @trace(inv_gamma(hyperparams["tyLSShape"], hyperparams["tyLSScale"]), :tyLS)
    xtLS = @trace(MappedGenerateLS(fill(hyperparams["xtLSShape"], nX), 
                                   fill(hyperparams["xtLSScale"], nX)), :xtLS)
    xyLS = @trace(MappedGenerateLS(fill(hyperparams["xyLSShape"], nX), 
                                   fill(hyperparams["xyLSScale"], nX)), :xyLS)
    
#   Prior over Kernel Scale
    yScale = @trace(inv_gamma(hyperparams["yScaleShape"], hyperparams["yScaleScale"]), :yScale)
  
#   Generate Data 
    tyCovLog = rbfKernelLog(T, T, tyLS)
    Ycov = processCov(tyCovLog, yScale, yNoise)
    Y = @trace(mvnormal(fill(0, n), Ycov), :Y)

    return Y
end

end


