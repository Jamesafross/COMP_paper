using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL

HOMEDIR = homedir()
PROGDIR = "$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/2PopNextGen"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
global OutDATADIR="$HOMEDIR/NetworkModels_Data/2PopNextGen_Data"
include("./functions/Headers.jl")
include("$PROGDIR/GlobalFunctions/Headers.jl")
include("../../Balloon_Model/BalloonModel.jl")
include("$InDATADIR/getData.jl")



numThreads = 8
nWindows = 4
tWindows = 100
type_SC = "generated"
size_SC = 80
delay_digits=3
plasticityOpt="off"
mode="rest"
n_Runs=1
eta_0E = -14.19
kappa = 0.505

const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density =0.5)


const plot_fit,save_data,ss,NGp,start_adapt,nP,bP,LR,IC,κS,wS,opts,vP,aP,HISTMAT,d,nRuns,timer =
setup(numThreads,nWindows,tWindows;plasticityOpt=plasticityOpt)


run_nextgen()