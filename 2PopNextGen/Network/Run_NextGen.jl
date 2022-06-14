using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL

HOMEDIR = homedir()
WORKDIR="$HOMEDIR/COMP_paper/2PopNextGen"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
OutDATADIR="$HOMEDIR/NetworkModels_Data/2PopNextGen_Data"
include("./functions/headers.jl")
include("$HOMEDIR/COMP_paper/global_functions/headers.jl")
include("../../Balloon_Model/BalloonModel.jl")
include("$InDATADIR/getData.jl")
include("setup.jl")

include("$WORKDIR/Network/functions/RunNetworkFunc.jl")

numThreads = 6
nWindows = 10
tWindows = 100
type_SC = "generated"
size_SC = 200
delay_digits=2
plasticityOpt="on"
mode="rest"
n_Runs=1
eta_0E = -14.19
kappa = 0.505

const SC,dist,lags,N,minSC,W_sum = NetworkSetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density =0.3)


const plot_fit,save_data,NGp,start_adapt,init0,nP,bP,LR,IC,κS,wS,opts,vP,aP,HISTMAT,d,nRuns,timer =
setup(numThreads,nWindows,tWindows)


Run_NextGen()