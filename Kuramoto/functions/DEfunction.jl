function Kuramoto(dθ,θ,h,p,t)
    hparams=p
    @unpack W,dist,lags,N,minSC,W_sum = nP
    @unpack ω,κ,σ = KP

    makeHistMat!(HISTMAT,h,θ,hparams,N,lags,t)
    make_d!(d,W,θ,HISTMAT)


    for i = 1:N
        dθ[i] = ω + κ*d[i]
    end
end

function dW(dθ,θ,h,p,t)
    @unpack W,dist,lags,N,minSC,W_sum = nP
    @unpack  ω,κ,σ = KP
    for i = 1:N
        dθ[i] = σ
    end
end
