include("functions/WC_InitSetupDistributed.jl")

@everywhere begin 
    parallel = "off"
    tWindows = 100
    nWindows = 6
    nTrials = 1
    type_SC = "paulData"
    size_SC =20
    densitySC=0.3
    delay_digits=10
    plasticity="off"
    mode="rest"
    c = 13000
    constant_delay = 0.005
    delays = "on"
    ISP = "off"
    plotdata = true
    normaliseSC = true
end


nVec1 = 40
nVec2 = 20
nVec3 = 20
PextVec = SharedArray(Array(LinRange(0.28,0.30,nVec1)))
etaVec = SharedArray(Array(LinRange(0.18,0.22,nVec2)))
cVec = SharedArray(Array(LinRange(5000,15000,nVec3)))

fitArray = SharedArray(zeros(nVec1,nVec2,nVec3))
fitArrayStruct = Array{fitStruct}(undef,nVec1,nVec2,nVec3)

@sync @distributed for i = 1:nVec1;
    for j = 1:nVec2
        for ij = nVec3
            global WCp = WCparams(Pext = PextVec[i],η=etaVec[j])
            SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(c;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC,normalise=normaliseSC)
            lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay
            W = zeros(N,N)
            W.=SC
            nP = networkParameters(W, dist,lags, N,minSC,W_sum)
            global BOLD_TRIALS,solverStruct = setup(nWindows,tWindows,nTrials,nP;parallel="off",delays="on",plasticity="on",mode="rest",ISP="off",WCpars = WCp)
            BOLD_TRIALS[:,:,:] = WC_run_trials()
            println("Done Trials!")

            modelFC = getModelFC(BOLD_TRIALS,nTrials) 
            FC_fit_to_data_mean = zeros(size(modelFC,3))
            for j = 1:size(modelFC,3)
                FC_fit_to_data_mean[j] = fit_r(modelFC[:,:,j],mean(FC_Array[:,:,:],dims=3)[:,:])
            end
            fitArray[i,j,ij] = maximum(FC_fit_to_data_mean)
        end
    end;
end

for i = 1:nVec1
    for j = 1:nVec2
        for ij = 1:nVec3
        fitArrayStruct[i,j] = fitStruct(cVec[ij],etaVec[j],PextVec[i],fitArray[i,j,ij])
        end
    end
end


save("$WORKDIR/WilsonCowan_fitVec.jld","fitArrayStruct",fitArrayStruct)



    
