global numThreads = 12

global nWindows = 4
global tWindows = 100
global type_SC = "generated"
global size_SC = 20
global densitySC= 0.3
global delay_digits=3
global plasticityOpt="off"
global mode="rest"
global n_Runs=1
global eta_0E = -14.19
global kappa = 0.505
global delays = "on"
global multi_thread = "on"

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






