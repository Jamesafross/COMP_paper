function make_uhist(tgrid,u)
    sizeT = size(tgrid,1)

    t = LinRange(tgrid[1],tgrid[end],size(u,2))
    interp = []
    for i = 1:size(u,1)
        if i == 1
            interp = [CubicSplineInterpolation(t,u[i,:])]
        else
            interp = cat(interp,[CubicSplineInterpolation(t,u[i,:])],dims=1) 
        end
    end
    return interp
end


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

function stim(t,i,stimNodes,Tstim,nRun,stimOpt)
    if i ∈ stimNodes && (Tstim[1] <t < Tstim[2]) && (stimOpt == "on" || stimOpt == "ON")
        return -1.
    else
        return 0.
    end
end



function normalise(W,N)

   for ii = 1:N
    W[W .< 0.0] .= 0.0
        if sum(W[:,ii]) != 0.0
        @views W[:,ii] = W[:,ii]./sum(W[:,ii])
        end

    end

     @inbounds for k=1:N #Maintaining symmetry in the weights between regions
        @inbounds for l = k:N
                 W[k,l] = (W[k,l]+W[l,k])/2
                 W[l,k] = W[k,l]
        end
    end
    return W
end


function adapt_local_func(h,hparams,t,κS,NGp,rE,rI,i,N,c;type = "lim")
    @unpack ΔE,ΔI,η_0E,η_0I,τE,τI,αEE,αIE,αEI,αII,κSEE,κSIE,κSEI,
    κSII,κVEE,κVIE,κVEI,κVII,VsynEE,VsynIE,VsynEI,VsynII,κ = NGp
    @unpack κSEEv,κSIEv,κSEIv,κSIIv,κSUM = κS
    
    κSEEv[i] = (κSEEv[i] + c*rE*(rE - h(hparams,t-1.0;idxs = i)))
    κSIEv[i] = (κSIEv[i] + c*rE*(rI - h(hparams,t-1.0;idxs = i+N)))
    κSEIv[i] = (κSEIv[i] + c*rI*(rE - h(hparams,t-1.0;idxs = i)))
    κSIIv[i] = (κSIIv[i] + c*rI*(rI - h(hparams,t-1.0;idxs = i+N)))
    
    limEE = 0.2
    limEI = 0.2
    limIE = 0.2
    limII = 0.2

    if type == "lim"
        if κSEEv[i]  > κSEE + limEE
            κSEEv[i] = κSEE + limEE
        elseif κSEEv[i]  < κSEE - limEE
            κSEEv[i] = κSEE - limEE
        end

        if κSEIv[i]  > κSEI + limEI
            κSEIv[i] = κSEI + limEI
        elseif κSEIv[i]  < κSEI - limEI
            κSEIv[i] = κSEI - limEI
        end

        if κSIEv[i]  > κSIE + limIE
            κSIEv[i] = κSIE + limIE
        elseif κSIEv[i]  < κSIE - limIE
            κSIEv[i] = κSIE - limIE
        end

        if κSIIv[i]  > κSII + limII
            κSIIv[i] = κSII + limII
        elseif κSIIv[i]  < κSII - limII
            κSIIv[i] = κSII - limII
        end
    elseif type == "normalised"
        κSEEv[i], κSIEv[i],κSEIv[i], κSIIv[i] = κSUM*[κSEEv[i], κSIEv[i], κSEIv[i], κSIIv[i]]/(κSEEv[i] + κSIEv[i] + κSEIv[i] + κSIIv[i])
    end

return κSEEv[i],κSIEv[i],κSEIv[i],κSIIv[i]
end


function adapt_local_func_nodelay(weights,WCp,E,I,i,c;type = "lim")
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ = WCp
    @unpack cSEEv,cSIEv,cSEIv,cSIIv,cSUM = weights

    cSEEv[i] = cSEEv[i] + c*rE*(rE)
    cSIEv[i] = cSIEv[i] + c*rE*(rI)
    cSEIv[i] = κSEIv[i] + c*rI*(rE)
    cSIIv[i] = cSIIv[i] + c*rI*(rI)

    limEE = 0.2
    limEI = 0.2
    limIE = 0.2
    limII = 0.2

    if type == "lim"
        if cSEEv[i]  > cSEE + limEE
            cSEEv[i] = cSEE + limEE
        elseif cSEEv[i]  < cSEE - limEE
            cSEEv[i] = cSEE - limEE
        end

        if cSEIv[i]  > cSEI + limEI
            cSEIv[i] = cSEI + limEI
        elseif cSEIv[i]  < cSEI - limEI
            cSEIv[i] = cSEI - limEI
        end

        if cSIEv[i]  > cSIE + limIE
            cSIEv[i] = cSIE + limIE
        elseif cSIEv[i]  < cSIE - limIE
            cSIEv[i] = cSIE - limIE
        end

        if cSIIv[i]  > cSII + limII
            cSIIv[i] = cSII + limII
        elseif cSIIv[i]  < cSII - limII
            cSIIv[i] = cSII - limII
        end
    elseif type == "normalised"
        cSEEv[i], cSIEv[i],cSEIv[i], cSIIv[i] = cSUM*[cSEEv[i], cSIEv[i], cSEIv[i], cSIIv[i]]/(cSEEv[i] + cSIEv[i] + cSEIv[i] + cSIIv[i])
    end

    return cSEEv[i],cSIEv[i],cSEIv[i],cSIIv[i]
end

	

