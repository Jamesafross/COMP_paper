function adapt_global_coupling(hparams,N::Int64,W::Matrix{Float64},lags::Matrix{Float64},h,t::Float64,u::Vector{Float64},minSC::Float64,W_sum::Vector{Float64},vP)
    @inbounds for ii = 1:N
        @inbounds for jj = 1:N
            if W[jj,ii]  > 0.0
                if lags[jj,ii] == 0.0
                     W[jj,ii] += 0.1*u[ii]*(u[jj] - h(hparams,t-1.0;idxs=jj))
                else
                     W[jj,ii] += 0.1*h(hparams,t-lags[jj,ii];idxs=ii)*(u[jj] - h(hparams,t-1.0;idxs=jj))
                end
            end
        end
        W[0. .< W .< minSC] .= minSC
        if sum(W[:,ii]) != 0.0
        @views W[:,ii] = W_sum[ii].*(W[:,ii]./sum(W[:,ii]))
        end

    end

     @inbounds for k=1:N #Maintaining symmetry in the weights between regions
        @inbounds for l = k:N
                 W[k,l] = (W[k,l]+W[l,k])/2
                 W[l,k] = W[k,l]
        end
    end


    vP.timeAdapt += 0.01
    vP.tPrev = maximum([vP.tPrev,t])


    return W
  
end


f(x::Float64,β::Float64,θ::Float64) = 1/(1+exp(-β*(x-θ)))





function adapt_local_func(h,hparams,t,κS,NGp,rE,rI,i,N,c;type = "lim")
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ = WCp
    @unpack cEEv,cIEv,cEIv,cIIv,cSUM = weights
    
    cEEv[i] = (cEEv[i] + c*rE*(rE - h(hparams,t-1.0;idxs = i)))
    cIEv[i] = (cIEv[i] + c*rE*(rI - h(hparams,t-1.0;idxs = i+N)))
    cEIv[i] = (cEIv[i] + c*rI*(rE - h(hparams,t-1.0;idxs = i)))
    cIIv[i] = (cIIv[i] + c*rI*(rI - h(hparams,t-1.0;idxs = i+N)))
    
    limEE = 0.2
    limEI = 0.2
    limIE = 0.2
    limII = 0.2

    if type == "lim"
        if cEEv[i]  > cEE + limEE
            cEEv[i] = cEE + limEE
        elseif cEEv[i]  < cEE - limEE
            cEEv[i] = cEE - limEE
        end

        if cEIv[i]  > cEI + limEI
            cEIv[i] = cEI + limEI
        elseif cEIv[i]  < cEI - limEI
            cEIv[i] = cEI - limEI
        end

        if cIEv[i]  > cIE + limIE
            cIEv[i] = cIE + limIE
        elseif cIEv[i]  < cIE - limIE
            cIEv[i] = cIE - limIE
        end

        if cIIv[i]  > cII + limII
            cIIv[i] = cII + limII
        elseif cIIv[i]  < cII - limII
            cIIv[i] = cII - limII
        end
    elseif type == "normalised"
        cEEv[i], cIEv[i],cEIv[i], cIIv[i] = cSUM*[cEEv[i], cIEv[i], cEIv[i], cIIv[i]]/(cEEv[i] + cIEv[i] + cEIv[i] + cIIv[i])
    end

return cEEv[i],cIEv[i],cEIv[i],cIIv[i]
end


function adapt_local_func_nodelay(weights,WCp,E,I,i,c;type = "lim")
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ = WCp
    @unpack cEEv,cIEv,cEIv,cIIv,cSUM = weights

    cEEv[i] = cEEv[i] + c*rE*(rE)
    cIEv[i] = cIEv[i] + c*rE*(rI)
    cEIv[i] = cEIv[i] + c*rI*(rE)
    cIIv[i] = cIIv[i] + c*rI*(rI)

    limEE = 0.2
    limEI = 0.2
    limIE = 0.2
    limII = 0.2

    if type == "lim"
        if cEEv[i]  > cEE + limEE
            cEEv[i] = cEE + limEE
        elseif cEEv[i]  < cEE - limEE
            cEEv[i] = cEE - limEE
        end

        if cEIv[i]  > cEI + limEI
            cEIv[i] = cEI + limEI
        elseif cEIv[i]  < cEI - limEI
            cEIv[i] = cEI - limEI
        end

        if cIEv[i]  > cIE + limIE
            cIEv[i] = cIE + limIE
        elseif cIEv[i]  < cIE - limIE
            cIEv[i] = cIE - limIE
        end

        if cIIv[i]  > cII + limII
            cIIv[i] = cII + limII
        elseif cIIv[i]  < cII - limII
            cIIv[i] = cII - limII
        end
    elseif type == "normalised"
        cEEv[i], cIEv[i],cEIv[i], cIIv[i] = cSUM*[cEEv[i], cIEv[i], cEIv[i], cIIv[i]]/(cEEv[i] + cIEv[i] + cEIv[i] + cIIv[i])
    end

    return cEEv[i],cIEv[i],cEIv[i],cIIv[i]
end

	

