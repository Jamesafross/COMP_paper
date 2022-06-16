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
    type_SC = "paulData"
    size_SC =50
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


kappa = "_kappa=$(NGp.κ)"
etaE = "etaE=$(NGp.η_0E)"

dir0 = "LR_"
dir1 = string(LR)
dir2 = "_StimStr_"
dir3 = string(opts.stimStr)

savename = kappa*etaE*dir0*dir1*dir2*dir3

savedir = dir0*dir1*dir2*dir3



if save_data == "true"
    println("saving BOLD data and synaptic weights")
    save("$OutDATADIR/BOLD/BOLD_$savename.jld","BOLD_$savename",BOLD)
    save("$OutDATADIR/weights/weights_$savename.jld","weights_$savename",wS)
end

time_per_second = timer.meanIntegrationTime/tWindows






