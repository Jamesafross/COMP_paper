workdir = "$(homedir())/COMP_paper/2PopNextGen/Network"

include("$workdir/functions/RunNetworkFunc.jl")

Run_NextGen(4,1,100;eta_0E = -14.19,kappa=0.505)