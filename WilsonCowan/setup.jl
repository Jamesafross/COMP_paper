using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,LinearAlgebra,Interpolations,Distributed

    include("functions/functions.jl")
    include("../Balloon_Model/balloonModelFunctions.jl")
    include("../Balloon_Model/balloonModelRHS.jl")
    include("../Balloon_Model/parameter_sets.jl")
    include("functions/Structures.jl")
    include("functions/DEfunctions.jl")
    include("functions/RunWilsonCowanFunc.jl")
    HOMEDIR=homedir()
    WORKDIR="$HOMEDIR/COMP_paper/WilsonCowan_Distributed"
    InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
    include("$InDATADIR/getData.jl")
    include("$HOMEDIR/COMP_paper/global_functions/headers.jl")
    #load data and make struct & dist matrices
   

    stimOpt = "off"
    stimWindow = 2
    stimNodes = [39]
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


