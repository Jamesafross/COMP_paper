HOMEDIR=homedir()
PROGDIR="$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/WilsonCowan"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
BALLOONDIR="$PROGDIR/Balloon_Model"
include("$BALLOONDIR/BalloonModel.jl")
include("$WORKDIR/functions/WC_Headers.jl")
include("$InDATADIR/getData.jl")



const SC,dist,lags,N,minSC,W_sum,FC_Array = networksetup(c;digits=delay_digits,type_SC=type_SC,N=size_SC,density=densitySC,normalise=normaliseSC)
lags[lags .> 0.0] = lags[lags .> 0.0] .+ constant_delay


if parallel == "on"
    @error "not implemented"
else
    const BOLD_TRIALS,ss,WCp,vP,aP,start_adapt,nP,bP,LR,IC,weights,wS,opts,WHISTMAT,d,timer,ONES = 
    setup(nWindows,tWindows,nTrials;plasticityOpt=plasticityOpt,mode=mode,ISP=ISP,WCpars = WCpars)
end

if parallel == "on"
    @error "not implemented"

else
    BOLD_TRIALS = WC_run_trials()
end






    
