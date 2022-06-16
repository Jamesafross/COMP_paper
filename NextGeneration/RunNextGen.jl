using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL

HOMEDIR = homedir()
PROGDIR = "$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/NextGeneration"
BALLOONDIR="$PROGDIR/Balloon_Model"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
OutDATADIR="$HOMEDIR/NetworkModels_Data/2PopNextGen_Data"
include("$WORKDIR/functions/NextGen_Headers.jl")
include("$PROGDIR/GlobalFunctions/Global_Headers.jl")
include("$BALLOONDIR/BalloonModel.jl")
include("$InDATADIR/getData.jl")

use_params = 1
if use_params == 1
    numThreads = Threads.nthreads()
    nWindows = 10
    tWindows = 100
    type_SC = "generated"
    size_SC =500
    densitySC=0.3
    delay_digits=10
    plasticityOpt="on"
    mode="rest"
    n_Runs=1
    eta_0E = -14.19
    kappa = 0.505
    delays = "off"
end

const multi_thread = "on"

const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)


const plot_fit,save_data,ss,NGp,start_adapt,nP,bP,LR,IC,κS,wS,opts,vP,aP,WHISTMAT,d,nRuns,timer,ONES,non_zero_weights =
setup(numThreads,nWindows,tWindows;delays=delays,plasticityOpt=plasticityOpt)


run_nextgen()

time_per_second = timer.meanIntegrationTime/tWindows






