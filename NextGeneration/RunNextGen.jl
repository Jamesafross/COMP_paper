include("./functions/NextGen_InitSetup.jl")


println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")
nWindows = 2
tWindows = 300
type_SC = "pauldata"
size_SC = 200
densitySC= 0.3
delay_digits=6
plasticityOpt="off"
mode="rest"  #(rest,stim or rest+stim)
n_Runs=1
eta_0E = -16
kappa = 0.8
delays = "on"
multi_thread = "on"
constant_delay = 0.005
if numThreads == 1
    global multi_thread = "off"
end

c = 12000

plotdata = "true"

include("$HOMEDIR/COMP_paper/NextGeneration/RunNextGenBase.jl")



time_per_second = timer.meanIntegrationTime/tWindows
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






