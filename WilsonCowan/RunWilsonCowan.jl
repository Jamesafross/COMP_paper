using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,Interpolations,Distributed
HOMEDIR=homedir()
PROGDIR="$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/WilsonCowan"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
BALLOONDIR="$PROGDIR/Balloon_Model"
include("$BALLOONDIR/BalloonModel.jl")
include("$WORKDIR/functions/WC_Headers.jl")
include("$InDATADIR/getData.jl")

global parallel = "off"
global tWindows = 300
global nWindows = 2
global nTrials = 1
global type_SC = "paulData"
global size_SC =20
global densitySC=0.3
global delay_digits=10
global plasticityOpt="off"
global mode="rest"
global c = 13000
global constant_delay = 0.005
global delays = "on"
global ISP = "off"
plotdata = true
normaliseSC = true


global WCpars = WCparams(Pext = 0.31,η=0.21)


include("RunWilsonCowanBase.jl")


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
            FC_fit_to_data_mean[i] = fit_r(modelFC[:,:,i],mean(FC_Array[:,:,:],dims=3))
            for j = 1:size(FC_Array,3)
                FC_fit_to_data[i,j] = fit_r(modelFC[:,:,i],FC_Array[:,:,j])
            end
        end

        println("max fit = ", maximum(FC_fit_to_data_mean))
        plot(FC_fit_to_data_mean)
    end









    
