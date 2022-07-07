using Distributed,SharedArrays

if nprocs() < 4
    addprocs(4)
    println("Number of Workers = ", nworkers())
end
#includes

@everywhere begin 
    using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,Interpolations,Distributed

    HOMEDIR=homedir()
    PROGDIR="$HOMEDIR/COMP_paper"
    WORKDIR="$PROGDIR/WilsonCowan"
    InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
    BALLOONDIR="$PROGDIR/Balloon_Model"
    include("$BALLOONDIR/BalloonModel.jl")
    include("$WORKDIR/functions/WC_Headers.jl")
    include("$InDATADIR/getData.jl")
    include("../RunWilsonCowanBaseFunc.jl")
end


    

