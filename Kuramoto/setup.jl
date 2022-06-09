#includes 
using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL,StochasticDelayDiffEq

HOMEDIR = homedir()
WORKDIR="$HOMEDIR/NetworkModels/2PopNextGen"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
OutDATADIR="$HOMEDIR/NetworkModels_Data/2PopNextGen_Data"
include("./functions/DEfunction.jl")
include("./functions/parameters.jl")
include("../Balloon_Model/BalloonModel.jl")
include("$InDATADIR/getData.jl")



c=7000.
SC_Array,FC_Array,dist = getData_nonaveraged(;SCtype="log")
FC_Array = FC_Array
PaulFCmean = mean(FC_Array,dims=3)
lags = dist./c
lags = round.(lags,digits=3) 
#lags[lags.<0.003] .= 0.000
#lags[SC .< 0.018] .= 0  
SC = 0.01SC_Array[:,:,1]
minSC,W_sum=getMinSC_and_Wsum(SC)
N = size(SC,1)
W = zeros(N,N)
W.=SC

const nP = networkParameters(W, dist,lags, N, minSC,W_sum)
const KP = KuramotoParams(ω = 2.)