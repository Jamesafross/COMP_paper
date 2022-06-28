
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
include("$PROGDIR/StatisticalAnalysis/get_fitness.jl")
include("$PROGDIR/StatisticalAnalysis/functions.jl")


DDEalg = BS3()
ODEalg = BS3()



if multi_thread == "off"
    nextgen(du,u,h,p,t) = nextgen_unthreads(du,u,h,p,t)
else
    nextgen(du,u,h,p,t) = nextgen_threads(du,u,h,p,t)
end

if lowercase(type_SC) == lowercase("paulData")
    const SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)
else
    const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)
end

const ss,NGp,start_adapt,nP,bP,LR,IC,κS,wS,opts,vP,aP,WHISTMAT,d,nRuns,timer,ONES,non_zero_weights =
setup(numThreads,nWindows,tWindows;delays=delays,plasticityOpt=plasticityOpt)

run_nextgen()

time_per_second = timer.meanIntegrationTime/tWindows
