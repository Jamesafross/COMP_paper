using LinearAlgebra,Plots,StochasticDelayDiffEq,Parameters,Statistics,StatsBase,DifferentialEquations,JLD,Interpolations,Distributed

@static if Sys.islinux() 
    using ThreadPinning,MKL
    ThreadPinning.mkl_set_dynamic(0)
    pinthreads(:compact)
end

numThreads = Threads.nthreads()
if numThreads > 1
    LinearAlgebra.BLAS.set_num_threads(1)
end
BLASThreads = LinearAlgebra.BLAS.get_num_threads()

println("Base Number of Threads: ",numThreads," | BLAS number of Threads: ", BLASThreads,".")

HOMEDIR=homedir()
PROGDIR="$HOMEDIR/COMP_paper"
WORKDIR="$PROGDIR/WilsonCowan"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
BALLOONDIR="$PROGDIR/Balloon_Model"
include("$BALLOONDIR/BalloonModel.jl")
include("$WORKDIR/functions/WC_Headers.jl")
include("$InDATADIR/getData.jl")``
include("../RunWilsonCowanBaseFunc.jl")