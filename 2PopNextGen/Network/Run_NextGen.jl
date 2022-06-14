using LinearAlgebra,MAT,JLD,DifferentialEquations,Plots,Random,NLsolve,Statistics,Parameters,Interpolations,MKL

HOMEDIR = homedir()
WORKDIR="$HOMEDIR/COMP_paper/2PopNextGen"
InDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
OutDATADIR="$HOMEDIR/NetworkModels_Data/2PopNextGen_Data"
include("./functions/NextGenFunctions.jl")
include("../../Balloon_Model/BalloonModel.jl")
include("$InDATADIR/getData.jl")



include("$WORKDIR/functions/RunNetworkFunc.jl")



Run_NextGen(4,1,100;eta_0E = -14.19,kappa=0.505)