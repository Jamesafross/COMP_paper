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
include("$PROGDIR/StatisticalAnalysis/get_fitness.jl")
include("$PROGDIR/StatisticalAnalysis/functions.jl")

use_params = 1
if use_params == 1
    numThreads = Threads.nthreads()
    nWindows = 10
    tWindows = 100
    type_SC = "paulDATA"
    size_SC =50
    densitySC=0.3
    delay_digits=3
    plasticityOpt="on"
    mode="rest"
    n_Runs=1
    eta_0E = -14.16
    kappa = 0.505
    delays = "on"
    save_data = "false"
    global multi_thread = "on"
end

DDEalg = BS3()
ODEalg = BS3()




if multi_thread == "off"
    nextgen(du,u,h,p,t) = nextgen_unthreads(du,u,h,p,t)
else
    nextgen(du,u,h,p,t) = nextgen_threads(du,u,h,p,t)
end


const SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)


const ss,NGp,start_adapt,nP,bP,LR,IC,κS,wS,opts,vP,aP,WHISTMAT,d,nRuns,timer,ONES,non_zero_weights =
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



#if save_data == "true"
  #  println("saving BOLD data and synaptic weights")
   # save("$OutDATADIR/BOLD/BOLD_$savename.jld","BOLD_$savename",BOLD)
    #save("$OutDATADIR/weights/weights_$savename.jld","weights_$savename",wS)
#end

time_per_second = timer.meanIntegrationTime/tWindows

modelFC = get_fitness(BOLD.BOLD_rest,1)
FC_fit_to_data = zeros(size(modelFC,3),size(FC_Array,3))

FC_fit_to_data_mean = zeros(size(modelFC,3))

for i = 1:size(modelFC,3)
    FC_fit_to_data_mean[i] = fitR(modelFC[:,:,i],mean(FC_Array[:,:,:],dims=3))
    for j = 1:size(FC_Array,3)
        FC_fit_to_data[i,j] = fitR(modelFC[:,:,i],FC_Array[:,:,j])
    end
end

plot(FC_fit_to_data_mean)






