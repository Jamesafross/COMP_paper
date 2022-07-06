using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations
HOMEDIR=homedir()

@static if Sys.islinux() 
    using MKL
    if Threads.nthreads() > 1 
        using ThreadPinning
        ThreadPinning.mkl_set_dynamic(0)
        pinthreads(:compact)
    end
end

numThreads = Threads.nthreads()
if numThreads > 1
    LinearAlgebra.BLAS.set_num_threads(1)
end
BLASThreads = LinearAlgebra.BLAS.get_num_threads()

println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")

nVec1 = 30
eta_0E_vec = LinRange(-13.0,-15,nVec1)

nVec2 = 1
#kappa_vec = LinRange(0.3,0.6,nVec2)
fitnessVec = zeros(nVec1,nVec2)
for i = 1:nVec1; for j = 1:nVec2;
    global nWindows = 2
    global tWindows = 300
    global type_SC = "pauldata"
    global size_SC = 200
    global densitySC= 0.3
    global delay_digits=6
    global plasticityOpt="off"
    global mode="rest"  #(rest,stim or rest+stim)
    global n_Runs=1
    global eta_0E = eta_0E_vec[i]
    global kappa = 0.505
    global delays = "on"
    global multi_thread = "on"
    global constant_delay = 0.005
    if numThreads == 1
        global multi_thread = "off"
    end
    println("Running trial for: η0E = ",eta_0E," κ = ", kappa)
    global c = 12000

    include("$HOMEDIR/COMP_paper/NextGeneration/RunNextGenBase.jl")

    kappa = "_kappa=$(NGp.κ)"
    etaE = "etaE=$(NGp.η_0E)"


    time_per_second = timer.meanIntegrationTime/tWindows
    print(time_per_second)


    modelFC = get_FC(BOLD.BOLD_rest)
    FC_fit_to_data = zeros(size(modelFC,3),size(FC_Array,3))

    FC_fit_to_data_mean = zeros(size(modelFC,3))

    for i = 1:size(modelFC,3)
        FC_fit_to_data_mean[i] = fit_r(modelFC[:,:,i],mean(FC_Array[:,:,:],dims=3))
        for j = 1:size(FC_Array,3)
            FC_fit_to_data[i,j] = fit_r(modelFC[:,:,i],FC_Array[:,:,j])
        end
    end

    print(FC_fit_to_data_mean)
    fitnessVec[i,j] = maximum(FC_fit_to_data_mean)
end;end






