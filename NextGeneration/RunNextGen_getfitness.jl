using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations
HOMEDIR=homedir()

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

nVec = 20
eta_0E_vec = LinRange(-14.0,-14.5,nVec)
fitnessVec = zeros(nVec)
for i = 1:nVec
    global nWindows = 5
    global tWindows = 100
    global type_SC = "pauldata"
    global size_SC = 200
    global densitySC= 0.3
    global delay_digits=10
    global plasticityOpt="off"
    global mode="rest"  #(rest,stim or rest+stim)
    global n_Runs=1
    global eta_0E = eta_0E_vec[i]
    global kappa = 0.505
    global delays = "on"
    global multi_thread = "on"
    if numThreads == 1
        global multi_thread = "off"
    end

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
        FC_fit_to_data_mean[i] = fitR(modelFC[:,:,i],mean(FC_Array[:,:,:],dims=3))
        for j = 1:size(FC_Array,3)
            FC_fit_to_data[i,j] = fitR(modelFC[:,:,i],FC_Array[:,:,j])
        end
    end

    print(FC_fit_to_data_mean)
    fitnessVec[i] = maximum(FC_fit_to_data_mean)
end






