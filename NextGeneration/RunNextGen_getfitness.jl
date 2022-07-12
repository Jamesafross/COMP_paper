using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations

include("./functions/NextGen_InitSetup.jl")
println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")
nWindows = 4
tWindows = 200
type_SC = "pauldata"
size_SC = 140
densitySC= 0.3
delay_digits=6
plasticity="off"
mode="rest"  #(rest,stim or rest+stim)
n_Runs=1
eta_0E = -14.8
kappa = 0.2
delays = "on"
multi_thread = "on"
constant_delay = 0.005
if numThreads == 1
    global multi_thread = "off"
end
if multi_thread == "off"
    nextgen(du,u,h,p,t) = nextgen_unthreads(du,u,h,p,t)
else
    nextgen(du,u,h,p,t) = nextgen_threads(du,u,h,p,t)
end

c = 12000

plotdata = "true"
nVec1 = 5
eta_0E_vec = LinRange(-14.8,-15.0,nVec1)

nVec2 = 1
#kappa_vec = LinRange(0.3,0.6,nVec2)
fitnessVec = zeros(nVec1,nVec2)

if lowercase(type_SC) == lowercase("paulData")
    const SC,dist,lags,N,minSC,W_sum,FC,missingROIs = networksetup(c;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)
    lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay
    println("mean delay = ", mean(lags[lags .> 0.0]))
else
    const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC)
    FC_Array = []
end

const solverStruct =
setup(numThreads,nWindows,tWindows;delays=delays,mode=mode,plasticity=plasticity)


    
for i = 1:nVec1; 
    for j = 1:nVec2;
        for jj = 1:nVec3
            solverStruct.nP.lags = dist./c_vec[jj]
            solverStruct.nP.lags[solverStruct.nP.lags .> 0.0] = solverStruct.nP.lags[solverStruct.nP.lags .> 0.0] .+ constant_delay
            

            solverStruct.NGp.η_0E = eta_0E_vec[i]
            solverStruct.NGp.κ=kappa_vec[j]
            solverStruct.timer.meanIntegrationTime = 0.0 
            run_nextgen()
            
            time_per_second = solverStruct.timer.meanIntegrationTime/tWindows
            print(time_per_second)

            modelFC = get_FC(BOLD.BOLD_rest)
            if size(missingROIs,1) > 0
                keepElements = ones(N)
                for i in missingROIs
                    keepElements .= collect(1:N) != i
                end

                modelFC = modelFC[keepElements,keepElements]
            end


            FC_fit_to_data_mean = zeros(size(modelFC,3))

            for k = 1:size(modelFC,3)
                FC_fit_to_data_mean[k] = fit_r(modelFC[:,:,k],FC)
            end


            fitnessVec[i,j,jj] = maximum(FC_fit_to_data_mean)

        end

    end
end;

print(maximum(fitnessVec))






