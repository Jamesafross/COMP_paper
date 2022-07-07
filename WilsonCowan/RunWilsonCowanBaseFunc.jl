function getSetup()
SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(c;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC,normalise=normaliseSC)
lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay
W = zeros(N,N)
W.=SC
nP = networkParameters(W, dist,lags, N,minSC,W_sum)
BOLD_TRIALS,ss,WCp,vP,aP,start_adapt,nP,bP,LR,IC,weights,wS,opts,WHISTMAT,d,timer,ONES = 
setup(nWindows,tWindows,nTrials,nP;parallel=parallel,plasticityOpt=plasticityOpt,mode=mode,ISP=ISP,WCpars = WCpars)

    return SC,dist,lags,N,minSC,W_sum,FC_Array,BOLD_TRIALS,ss,WCp,vP,aP,start_adapt,nP,bP,LR,IC,weights,wS,opts,WHISTMAT,d,timer,ONES
end










    
