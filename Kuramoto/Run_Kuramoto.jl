using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL,StochasticDelayDiffEq

HOMEDIR = homedir()
#WORKDIR="$HOMEDIR/NetworkModels/2PopNextGen"
PROGDIR = "$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/NextGeneration"
BALLOONDIR="$PROGDIR/Balloon_Model"
include("$PROGDIR/GlobalFunctions/Global_Headers.jl")
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
OutDATADIR="$HOMEDIR/NetworkModels_Data/Kuramoto"
include("./functions/Kuramoto_DEFunction.jl")
include("./functions/Kuramoto_Structures.jl")
include("functions/Kuramoto_WindowsRunFunc.jl")
include("functions/Kuramoto_Functions.jl")
include("../Balloon_Model/BalloonModel.jl")
include("$InDATADIR/getData.jl")




#for i = 1:size(W,2)
 #   W[i,:] = W[i,:]./sum(W[i,:])
#end


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

nWindows = 10
tWindows = 200
const BOLD_saveat = collect(0:1.6:tWindows)
const size_out = length(BOLD_saveat)


const KP = KuramotoParams(ω = 10.,κ=-0.03,σ=0.001)
const IC = Init(0.18randn(N))
const HISTMAT = zeros(N,N)
const d = zeros(N)
const opts=solverOpts(tWindows,nWindows)
const bP = ballonModelParameters()

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






