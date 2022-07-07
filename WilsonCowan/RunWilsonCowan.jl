using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,Interpolations,Distributed

@static if Sys.islinux() 
    using ThreadPinning,MKL
    ThreadPinning.mkl_set_dynamic(0)
    pinthreads(:compact)
end

numThreads = Threads.nthreads()
if numThreads > 1
    LinearAlgebra.BLAS.set_num_threads(1)
end
BLASThreads = LinearAlgebra.BLAS.get_num_threads()

println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")

HOMEDIR=homedir()
PROGDIR="$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/WilsonCowan"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
BALLOONDIR="$PROGDIR/Balloon_Model"
include("$BALLOONDIR/BalloonModel.jl")
include("$WORKDIR/functions/WC_Headers.jl")
include("$InDATADIR/getData.jl")

parallel = "off"
tWindows = 50
nWindows = 2
nTrials = 1
type_SC = "paulData"
size_SC =20
densitySC=0.3
delay_digits=10
plasticityOpt="off"
mode="rest"
c = 13000
constant_delay = 0.005
delays = "on"
ISP = "off"
plotdata = true
normaliseSC = true


WCpars = WCparams(Pext = 0.34,η=0.21)

for i = 1:3
include("RunWilsonCowanBase.jl")
end


time_per_second = timer.meanIntegrationTime/tWindows
print(time_per_second)

    function getModelFC(BOLD_TRIALS,nTrials)
        modelFC = []
        for i = 1:nTrials
            if i == 1
                modelFC = get_FC(BOLD_TRIALS[:,:,i])/nTrials
            else
                modelFC += get_FC(BOLD_TRIALS[:,:,i])/nTrials
            end
        end
        return modelFC
    end

    modelFC = getModelFC(BOLD_TRIALS,nTrials) 

    if lowercase(type_SC) == "pauldata" && plotdata == true
        
        FC_fit_to_data = zeros(size(modelFC,3),size(FC_Array,3))

        FC_fit_to_data_mean = zeros(size(modelFC,3))

        for i = 1:size(modelFC,3)
            FC_fit_to_data_mean[i] = fit_r(modelFC[:,:,i],mean(FC_Array[:,:,:],dims=3)[:,:])
            for j = 1:size(FC_Array,3)
                FC_fit_to_data[i,j] = fit_r(modelFC[:,:,i],FC_Array[:,:,j])
            end
        end

        println("max fit = ", maximum(FC_fit_to_data_mean))
        plot(FC_fit_to_data_mean)
    end









    
