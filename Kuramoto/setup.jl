#includes 
using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL,StochasticDelayDiffEq

HOMEDIR = homedir()
#WORKDIR="$HOMEDIR/NetworkModels/2PopNextGen"
PROGDIR = "$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/NextGeneration"
BALLOONDIR="$PROGDIR/Balloon_Model"
include("$PROGDIR/GlobalFunctions/Global_Headers.jl")
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
OutDATADIR="$HOMEDIR/NetworkModels_Data/Kuramoto"
include("./functions/Kuramoto_DEFunction.jl")
include("./functions/Kuramoto_Structures.jl")
include("functions/Kuramoto_WindowsRunFunc.jl")
include("functions/Kuramoto_Functions.jl")
include("../Balloon_Model/BalloonModel.jl")
include("$InDATADIR/getData.jl")




#for i = 1:size(W,2)
 #   W[i,:] = W[i,:]./sum(W[i,:])
#end
nWindows = 10
tWindows = 200
const BOLD_saveat = collect(0:1.6:tWindows)
const size_out = length(BOLD_saveat)


const KP = KuramotoParams(ω = 10.,κ=-0.03,σ=0.001)
const IC = Init(0.18randn(N))
const HISTMAT = zeros(N,N)
const d = zeros(N)
const opts=solverOpts(tWindows,nWindows)
const bP = ballonModelParameters()