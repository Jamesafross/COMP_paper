@with_kw struct WCparams{R}
    cEE::R = 3.5
    cEI::R  = 3.75
    cIE::R  = -2.5
    cII::R  = 0.
    θE::R  = 1.
    θI::R  = 1.
    β::R = 4.
    η::R  = 0.12
    σ::R  = 0.005
    τE::R  = 0.01
    τI::R  =0.02
    τx::R = .01
    Pext::R  =0.315
end

@with_kw struct WCparamsISP{R}
    cEE::R = 3.5
    cEI::R  = 3.75
    cIE::R  = -2.5
    cII::R  = 0.
    θE::R  = 1.
    θI::R  = 1.
    β::R = 4.0
    η::R  = 0.15
    σ::R  = 0.001
    τE::R  = 0.01
    τI::R  =0.02
    τx::R = .01
    Pext::R  =0.315
    τISP::R = 200.
    ρ::R = 0.15
end

mutable struct networkParameters
    W::Matrix{Float64}
    dist::Matrix{Float64}
    lags::Matrix{Float64}
    N::Int64
    minSC::Float64
    W_sum::Vector{Float64}
end

mutable struct fitStruct
    c
    eta
    Pext
    fit
end


mutable struct dataStruct
	modelR
	fit
	SC
end


mutable struct modelOpts
    stimOpt::String
    adapt::String
    ISP::String
end

mutable struct StimOptions
    stimOpt::String
    stimWindow::Real
    stimNodes::Vector{Real}
    stimStr::Real
    Tstim::Vector{Real}
end

mutable struct RunOptions
    tWindows::Real
    nWindows::Real
    StimSwitcher::Array{String}
end

mutable struct SolverOptions
    delays::String
    plasticity::String
    adapt::String
    ISP::String
end


mutable struct RunParameters
    counter::Int64
    WHISTMAT::Matrix{Float64}
    d::Vector{Float64}
end

mutable struct Weights
    cEEv
    cIEv
    cEIv
    cIIv
    cSUM
end

mutable struct weightsSave
    cEEv
    cIEv
    cEIv
    cIIv
    count
end

mutable struct WilsonCowanSolverStruct
    WCp
    nP
    bP
    IC
    weights
    wS
    stimOpts
    runOpts
    solverOpts
    runPars
    adaptPars
    nRuns
    timer
end


	
