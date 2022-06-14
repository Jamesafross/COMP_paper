using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,LinearAlgebra,Interpolations,Distributed

    include("functions/functions.jl")
    include("../Balloon_Model/balloonModelFunctions.jl")
    include("../Balloon_Model/balloonModelRHS.jl")
    include("../Balloon_Model/parameter_sets.jl")
    include("functions/Structures.jl")
    include("functions/DEfunctions.jl")
    include("functions/RunWilsonCowanFunc.jl")
    HOMEDIR=homedir()
    WORKDIR="$HOMEDIR/NetworkModels/WilsonCowan_Distributed"
    InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
    include("$InDATADIR/getData.jl")
    #load data and make struct & dist matrices
    c=7000.
    SC_Array,FC_Array,dist = getData_nonaveraged(;SCtype="log")
    FC_Array = FC_Array
    PaulFCmean = mean(FC_Array,dims=3)
    SC = 0.01*SC_Array[:,:,1]
    lags = dist./c
    lags = round.(lags,digits=3) 
    lags[lags.<0.003] .= 0.000
    #lags[SC .< 0.018] .= 0  
    minSC,W_sum=getMinSC_and_Wsum(SC)
    N = size(SC,1)
    W = zeros(N,N)
    W.=SC

    stimOpt = "off"
    stimWindow = 2
    stimNodes = [37]
    Tstim = [30,60]
    adapt = "off"
    const tWindows = 300.
    const nWindows = 10
    const nTrials = 2
    ISP = "off"

    const opts=solverOpts(stimOpt,stimWindow,stimNodes,Tstim,adapt,tWindows,nWindows,ISP)
    const nP = networkParameters(W, dist,lags, N,minSC,W_sum)
    const vP = variousPars(0.0, 50.0)
    const bP = ballonModelParameters()

    if opts.ISP == "on"
       const WCp = WCparamsISP()
    else
       const WCp= WCparams()
    end
    
    constnTrials = 1
    
    
    BOLD_saveat = collect(0:1.6:tWindows)
    size_out = length(BOLD_saveat)
    BOLD_TRIALS = zeros(N,nWindows*size_out,nTrials)


