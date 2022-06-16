using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,LinearAlgebra,Interpolations,Distributed

HOMEDIR=homedir()
PROGDIR="$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/WilsonCowan"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
BALLOONDIR="$PROGDIR/Balloon_Model"
include("$BALLOONDIR/BalloonModel.jl")
include("$WORKDIR/functions/Headers.jl")

include("$InDATADIR/getData.jl")



parallel = "off"
numThreads=8
tWindows = 300.
nWindows = 10
nTrials = 2
type_SC = "generated"
size_SC =500
densitySC=0.3
delay_digits=10
plasticityOpt="on"
mode="rest"

delays = "off"

const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density =0.3)


if parallel == "on"
else
    const plot_fit,save_data,ss,WCp,start_adapt,nP,bP,LR,IC,opts,WHISTMAT,d,timer = 
    setup(numThreads,nWindows,tWindows,nTrials;plasticityOpt="on",mode="rest")
end


if parallel == "on"

else
    BOLD_TRIALS = WC_trials()
end






    
