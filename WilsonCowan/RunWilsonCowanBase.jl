
const SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(c;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC,normalise=normaliseSC)
lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay

const BOLD_TRIALS,ss,WCp,vP,aP,start_adapt,nP,bP,LR,IC,weights,wS,opts,WHISTMAT,d,timer,ONES = 
setup(nWindows,tWindows,nTrials;parallel=parallel,plasticityOpt=plasticityOpt,mode=mode,ISP=ISP,WCpars = WCpars)

BOLD_TRIALS[:,:,:] = WC_run_trials()








    
