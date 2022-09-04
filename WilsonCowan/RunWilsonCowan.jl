include("functions/WC_InitSetup.jl")

parallel = "off"
tWindows = 1000
nWindows = 1
nTrials = 1
type_SC = "paulData"
size_SC =140
densitySC=0.3
delay_digits=10
plasticityOpt="on"
mode="stim"
c = 13000
constant_delay = 0.005
delays = "on"
ISP = "on"
plotdata = true
normaliseSC = true


nVec1 = 10
nVec2 = 10
PextVec = LinRange(0.29,0.30,nVec1)
etaVec = LinRange(0.19,0.22,nVec2)

fitVec = zeros(nVec1,nVec2)

if ISP == "off" 
    global WCp = WCparams(Pext = 0.302,η=0.15)
else
    global WCp = WCparamsISP(Pext = 0.25,η=0.1,σ = 0.1, ρ=0.15)
end
SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(c;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC,normalise=normaliseSC)
lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay
W = zeros(N,N)
W.=SC
nP = networkParameters(W, dist,lags, N,minSC,W_sum)
global BOLD_TRIALS,solverStruct = setup(nWindows,tWindows,nTrials,nP;parallel="off",delays="on",plasticity="on",mode="rest",ISP="off",WCpars = WCp)
BOLD_TRIALS[:,:,:] = WC_run_trials()

modelFC = getModelFC(BOLD_TRIALS,nTrials) 
FC_fit_to_data_mean = zeros(size(modelFC,3))
meanFC,missingROI = get_mean_all_functional_data(;ROI=140,type="control")

for j = 1:size(modelFC,3)
    FC_fit_to_data_mean[j] = fit_r(modelFC[:,:,j],meanFC)
end


save("$WORKDIR/saved_data/modelFC_stim.jld","modelFC_stim",modelFC)

time_per_second = solverStruct.timer.meanIntegrationTime/tWindows
print(time_per_second)







println(maximum(FC_fit_to_data_mean))
plot(FC_fit_to_data_mean)










    
