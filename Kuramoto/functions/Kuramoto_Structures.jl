mutable struct networkParameters
    W::Matrix{Float64}
    dist::Matrix{Float64}
    lags::Matrix{Float64}
    N::Int64
    minSC::Float64
    W_sum::Vector{Float64}
end


@with_kw struct KuramotoParams{R}
    ω::R = 0.1
    κ::R = -0.1
    σ::R = 0.001
end

mutable struct solverOpts
    tWindows::Real
    nWindows::Real
end

mutable struct Init
    u0
end
