function Kuramoto(dθ,θ,h,p,t)
    @unpack W,dist,lags,N,minSC,W_sum = nP
    @unpack  ω,κ,σ = KP

    for i = 1:N
        d = 0.
        for j = 1:N
            if W[i,j] > 0
                if lags[i,j] > 0
                    d += W[i,j]*sin(h(p,t-lags[i,j],idxs=j) - θ[i])
                else
                    d +=  W[i,j]*sin(θ[j] - θ[i])
                end
            end
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
