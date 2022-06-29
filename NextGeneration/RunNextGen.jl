using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,ThreadPinning,MKL
ThreadPinning.mkl_set_dynamic(0)
HOMEDIR=homedir()


counter_i = 1
numThreads = Threads.nthreads()
if numThreads > 1
    LinearAlgebra.BLAS.set_num_threads(1)
end
BLASThreads = LinearAlgebra.BLAS.get_num_threads()
pinthreads(:compact)


println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")

global nWindows = 4
global tWindows = 200
global type_SC = "pauldata"
global size_SC = 200
global densitySC= 0.3
global delay_digits=10
global plasticityOpt="off"
global mode="rest"
global n_Runs=1
global eta_0E = -14.19
global kappa = 0.505
global delays = "on"
global multi_thread = "on"

plotdata = "false"

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
end






