function makeHistMat!(HistMat::Array{Float64},h,u::Array{Float64},hparams,N,lags::Array{Float64},t::Float64)
    for i = 1:N
        for j = 1:N
            if lags[i,j] > 0.0
                HistMat[i,j] = h(hparams,t-lags[j,i]; idxs=j)
            else
                HistMat[i,j] = u[j]
            end
        end
    end
end

function make_d!(d,W,u,HistMat)

    for j = 1:N
        d[j] 
    end
    d .= sum(W.*sin.((HistMat.-u[1:N])),dims=2)
end
        
function h1(hparams,t;idxs = nothing)
    #history function used on first window
        if t < 0
            return IC.u0[idxs]
        end
end

function h2(hparams,t;idxs = nothing)
    #history function used on windows > 1
    
    #println(t)
    #println(idxs)
        if t < 0
            return hparams[idxs](t)
        end
end

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

