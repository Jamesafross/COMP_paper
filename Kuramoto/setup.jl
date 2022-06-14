#includes 
using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL,StochasticDelayDiffEq

HOMEDIR = homedir()
#WORKDIR="$HOMEDIR/NetworkModels/2PopNextGen"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
OutDATADIR="$HOMEDIR/NetworkModels_Data/Kuramoto"
include("./functions/DEfunction.jl")
include("./functions/structures.jl")
include("functions/RunKuramotoFunc.jl")
include("functions/functions.jl")
include("../Balloon_Model/BalloonModel.jl")
include("$InDATADIR/getData.jl")





c=7000.
SC_Array,FC_Array,dist = getData_nonaveraged(;SCtype="log")
FC_Array = FC_Array
PaulFCmean = mean(FC_Array,dims=3)
lags = dist./c
lags = round.(lags,digits=3)  
SC = 0.01SC_Array[:,:,1]
minSC,W_sum=getMinSC_and_Wsum(SC)
N = size(SC,1)
W = zeros(N,N)
W.=SC

#for i = 1:size(W,2)
 #   W[i,:] = W[i,:]./sum(W[i,:])
#end
nWindows = 10
tWindows = 200
const BOLD_saveat = collect(0:1.6:tWindows)
const size_out = length(BOLD_saveat)

const nP = networkParameters(W, dist,lags, N, minSC,W_sum)
const KP = KuramotoParams(ω = 10.,κ=-0.03,σ=0.001)
const IC = Init(0.18randn(N))
const HISTMAT = zeros(N,N)
const d = zeros(N)
const opts=solverOpts(tWindows,nWindows)
const bP = ballonModelParameters()