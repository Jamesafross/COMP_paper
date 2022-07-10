include("./functions/NextGen_InitSetup.jl")



println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")
nWindows = 4
tWindows = 200
type_SC = "pauldata"
size_SC = 200
densitySC= 0.3
delay_digits=6
plasticity="off"
mode="rest"  #(rest,stim or rest+stim)
n_Runs=1
eta_0E = -14.9
kappa = 0.1
delays = "on"
multi_thread = "on"
constant_delay = 0.005
if numThreads == 1
    global multi_thread = "off"
end

c = 12000

plotdata = "true"

if lowercase(type_SC) == lowercase("paulData")
    const SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(c;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)
    lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay
    println("mean delay = ", mean(lags[lags .> 0.0]))
else
    const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)
    FC_Array = []
end

NGp = NextGen2PopParams2()


const solverStruct =
setup(numThreads,nWindows,tWindows;delays=delays,mode=mode,plasticity=plasticity)

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






