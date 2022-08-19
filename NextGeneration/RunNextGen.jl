include("./functions/NextGen_InitSetup.jl")



println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")
nWindows = 110 #stimulation starts at window 10
tWindows =60
type_SC = "pauldata" #sizes -> [18, 64,140,246,503,673]
size_SC = 140
densitySC= 0.5
delay_digits=5
plasticity="on"
mode="stim"  #(rest,stim or rest+stim)
n_Runs=1
nFC = 1
nSC = 1
eta_0E = -15.56
kappa = 0.0505
delays = "on"
multi_thread = "on"
constant_delay = 0.002

doFC = true

if numThreads == 1
    global multi_thread = "off"
end

NGp = NextGen2PopParams2(η_0E = eta_0E,κ=kappa)

c = 12000

plotdata = "true"

if lowercase(type_SC) == lowercase("paulData")
    const SC,dist,lags,N,minSC,W_sum,FC,missingROIs = networksetup(c;digits=delay_digits,nSC=nSC,nFC=nFC,type_SC=type_SC,N=size_SC,density=densitySC)
    lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay
    println("mean delay = ", mean(lags[SC .> 0.0]))
else
    const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)
    FC_Array = []
end



const solverStruct =
setup(numThreads,nWindows,tWindows;delays=delays,mode=mode,plasticity=plasticity,NGp=NGp)

if multi_thread == "off"
    nextgen(du,u,h,p,t) = nextgen_unthreads(du,u,h,p,t)
else
    nextgen(du,u,h,p,t) = nextgen_threads(du,u,h,p,t)
end

BOLD = run_nextgen(solverStruct)

time_per_second = solverStruct.timer.meanIntegrationTime/tWindows
print(time_per_second)
meanFC,missingROI = get_mean_all_functional_data(;ROI=140,type="control")


if lowercase(type_SC) == "pauldata" && doFC == true

    if mode == "rest+stim" 
        modelFC = get_FC(BOLD.BOLD_rest)
        modelFC_stim = get_FC(BOLD.BOLD_stim)
        save("./saved_data/modelFC.jld","modelFC",modelFC)
        save("./saved_data/modelFC_stim.jld","modelFC_stim",modelFC_stim)
    elseif mode == "rest"
        modelFC = get_FC(BOLD.BOLD_rest)
        save("./saved_data/modelFC.jld","modelFC",modelFC)
    elseif mode == "stim"
        modelFC_stim = get_FC(BOLD.BOLD_stim)
        save("./saved_data/modelFC_stim.jld","modelFC_stim",modelFC_stim)
    end
 
    if mode == "rest" || mode == "rest+stim"
        if size(missingROI,1) > 0
            keepElements = ones(N)
            for i in missingROI
                keepElements .= collect(1:N) != i
            end

            modelFC = modelFC[keepElements,keepElements]
        end
        
        FC_fit_to_data_mean = zeros(size(modelFC,3))

        for i = 1:size(modelFC,3)
            FC_fit_to_data_mean[i] = fit_r(modelFC[:,:,i].^2,meanFC.^2)
        end


        print("best fitness = ", maximum(FC_fit_to_data_mean))
    end

end









 