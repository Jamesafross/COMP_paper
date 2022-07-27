include("./functions/NextGen_InitSetup.jl")



println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")
nWindows = 2
tWindows = 200
type_SC = "pauldata" #sizes -> [18, 64,140,246,503,673]
size_SC = 246
densitySC= 0.3
delay_digits=6
plasticity="off"
mode="rest"  #(rest,stim or rest+stim)
n_Runs=1
nFC = 1
nSC = 1
eta_0E = -13.
kappa = 0.5
delays = "on"
multi_thread = "on"
constant_delay = 0.005
if numThreads == 1
    global multi_thread = "off"
end

NGp = NextGen2PopParams2(η_0E = eta_0E,κ=kappa)

c = 12000

plotdata = "true"

if lowercase(type_SC) == lowercase("paulData")
    const SC,dist,lags,N,minSC,W_sum,FC,missingROIs = networksetup(c;digits=delay_digits,nSC=nSC,nFC=nFC,type_SC=type_SC,N=size_SC,density=densitySC)
    lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay
    println("mean delay = ", mean(lags[lags .> 0.0]))
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

run_nextgen()

time_per_second = solverStruct.timer.meanIntegrationTime/tWindows
print(time_per_second)

if lowercase(type_SC) == "pauldata" && plotdata =="true"
    modelFC = get_FC(BOLD.BOLD_rest)
    if size(missingROIs,1) > 0
        keepElements = ones(N)
        for i in missingROIs
            keepElements .= collect(1:N) != i
        end

        modelFC = modelFC[keepElements,keepElements]
    end


    FC_fit_to_data_mean = zeros(size(modelFC,3))

    for i = 1:size(modelFC,3)
        FC_fit_to_data_mean[i] = fit_r(modelFC[:,:,i],FC)
       
    end

    print(FC_fit_to_data_mean)
    plot(FC_fit_to_data_mean)

    end






