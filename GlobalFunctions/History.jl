function h1(hparams,t;idxs = nothing)
    #history function used on first window
        if t < 0
        return hparams[idxs]
    end
end

function h2(hparams,t;idxs = nothing)
    #history function used on windows > 1
        if t < 0
            return hparams[idxs](t)
        end
end