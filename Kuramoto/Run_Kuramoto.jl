include("./setup.jl")


numThreads = 6
nWindows = 10
tWindows = 100
type_SC = "generated"
size_SC =150
delay_digits=3
plasticityOpt="off"
mode="rest"
n_Runs=1
eta_0E = -14.19
kappa = 0.505
delays = "on"

const SC,dist,lags,N,minSC,W_sum = networksetup(;digits=delay_digits,type_SC=type_SC,N=size_SC,density =0.5)

W = zeros(N,N)
W.=SC
const nP = networkParameters(W, dist,lags, N, minSC,W_sum)

 

nTrials = 10
BOLD_OUT = zeros(N,size_out*nWindows)
BOLD_TRIAL_MEAN = zeros(N,size_out*nWindows)

for n = 1:nTrials
    IC.u0 = 0.18randn(N)
    
    out = KuramotoRun()

    for ii = 1:nWindows
        BOLD_OUT[:,1+size_out*(ii-1):ii*size_out]= out[:,:,ii] 
    end

    BOLD_TRIAL_MEAN += BOLD_OUT/nTrials

    
end




savedir = "Run_1"


save("$OutDATADIR/$savedir/BOLD_Kuramoto.jld","BOLD_Kuramoto",BOLD_TRIAL_MEAN)






