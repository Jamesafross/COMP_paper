using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,LinearAlgebra,Interpolations,Distributed

HOMEDIR=homedir()
PROGDIR="$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/WilsonCowan"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
BalloonDIR="$PROGDIR/Balloon_Model"
include("$WORKDIR/functions/Headers.jl")
include("$BalloonDIR/balloonModelFunctions.jl")
include("$BalloonDIR/balloonModelRHS.jl")
include("$BalloonDIR/parameter_sets.jl")
include("$InDATADIR/getData.jl")
include("$PROGDIR/GlobalFunctions/Headers.jl")


parallel = "off"
numThreads=8
tWindows = 300.
nWindows = 10
nTrials = 2

const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density =0.3)


if parallel == "on"
    include("setupDistributed.jl")
else
    setup(numThreads,nWindows,tWindows,nTrials;plasticityOpt="on",mode="rest")
end


if parallel == "on"

else
    BOLD_TRIALS = WC_trials()
end






    
