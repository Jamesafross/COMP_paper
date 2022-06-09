function Kuramoto(dθ,θ,h,p,t)
    @unpack W,dist,lags,N,minSC,W_sum = nP
    @unpack  ω,κ,σ = KP

    for i = 1:N
        d = 0.
        for j = 1:N
            d += W[i,j]*sin(h(p,t-lags[i,j],idxs=j) - θ[i])
        end
        dθ[i] = ω + κ*d
    end
end

function dW(dθ,θ,h,p,t)
    @unpack W,dist,lags,N,minSC,W_sum = nP
    @unpack  ω,κ,σ = KP
    for i = 1:N
        dθ[i] = σ
    end
end