include("./functions/NextGen_InitSetup.jl")


println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")

global nWindows = 2
global tWindows = 300
global type_SC = "pauldata"
global size_SC = 200
global densitySC= 0.3
global delay_digits=6
global plasticityOpt="off"
global mode="rest"  #(rest,stim or rest+stim)
global n_Runs=1
global eta_0E = -15.1
global kappa = 0.6
global delays = "on"
global multi_thread = "on"
global constant_delay = 0.005
if numThreads == 1
    global multi_thread = "off"
end

global c = 12000

plotdata = "true"

include("$HOMEDIR/COMP_paper/NextGeneration/RunNextGenBase.jl")



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
print(time_per_second)

if lowercase(type_SC) == "pauldata" && plotdata =="true"
modelFC = get_FC(BOLD.BOLD_rest)
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






