function Kuramoto(dθ,θ,h,p,t)
    NGp

    for i = 1:N
        d = 0.
        for j = 1:N
            d += W[i,j]*sin(h(p,t-lags[i,j],idxs=j) - θ[i])
        end
        dθ[i] = ω[i] + κ*d
    end
end

function dW(dθ,θ,h,p,t)
    for i = 1:N
        dθ[i] = σ
    end
end
