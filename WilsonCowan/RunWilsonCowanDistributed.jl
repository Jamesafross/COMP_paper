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
plasticityOpt="off"
mode="rest"
c = 13000
constant_delay = 0.005
delays = "on"
ISP = "off"
plotdata = true
normaliseSC = true
end


nVec1 = 12
nVec2 = 12
PextVec = SharedArray(Array(LinRange(0.28,0.30,nVec1)))
etaVec = SharedArray(Array(LinRange(0.18,0.22,nVec2)))

fitVec = SharedArray(zeros(nVec1,nVec2))

@sync @distributed for i = 1:nVec1;
    for j = 1:nVec2

    global WCpars = WCparams(Pext = PextVec[i],η=etaVec[j])
    global SC,dist,lags,N,minSC,W_sum,FC_Array,BOLD_TRIALS,ss,WCp,vP,aP,start_adapt,nP,bP,LR,IC,weights,wS,opts,WHISTMAT,d,timer,ONES = getSetup()
    BOLD_TRIALS[:,:,:] = WC_run_trials()
    println("Done Trials!")

    modelFC = getModelFC(BOLD_TRIALS,nTrials) 
    FC_fit_to_data_mean = zeros(size(modelFC,3))
    for j = 1:size(modelFC,3)
        FC_fit_to_data_mean[j] = fit_r(modelFC[:,:,j],mean(FC_Array[:,:,:],dims=3)[:,:])
    end
    fitVec[i,j] = maximum(FC_fit_to_data_mean)
    end;
end

plot(fitVec)



    
