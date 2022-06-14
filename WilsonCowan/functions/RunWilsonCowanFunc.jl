function WCRun(WCp,bP)
    adpTime = 15.0
    Rvec = zeros(N,N,nWindows)
    Wvec = zeros(N,N,nWindows)
    BOLD_saveat = collect(0:1.6:tWindows)
    size_out = length(BOLD_saveat)
    BOLD_out = zeros(N,size_out,nWindows)
    
    
        
    for j = 1:nWindows

        global nWindow = j
       
        println("working on window ",j)
        if j == 1
            u0 = 0.1rand(3N)
          
            hparams = u0
        else
            opts.stimOpt = "off"
            u0 = sol[:,end]
            iStart = findfirst(sol.t .> tWindows - 1.2)
            u_hist = make_uhist(sol.t[iStart:end] .- sol.t[end],sol[:,iStart:end])
            hparams = u_hist
           
            vP.tPrev = 0.0
            vP.timeAdapt = 0.01
        end
        
        tspan = (0.0,tWindows)
        #println(adpTime)
        clags = unique(lags[lags.>0])


        p = hparams
        if j == 1
            prob = SDDEProblem(WC, dW,u0, h1, tspan, p;constant_lags = clags)
        else
            prob = SDDEProblem(WC, dW,u0, h2, tspan, p;constant_lags = clags)
        end
        @time global sol = solve(prob,RKMil(),maxiters = 1e20)
       
        

        BalloonIn= make_In(sol.t,sol[1:N,:])
        tspanB = (sol.t[1],sol.t[end])
        balloonParams = bP,BalloonIn,N
        if j == 1
            b0 =  cat(zeros(N),ones(3N),dims=1)
        else
            b0 = endBM
        end
        println("Running Balloon Model")
        global out,endBM = runBalloon(b0,balloonParams,tspanB,BOLD_saveat,N)

    
        out_trans=(out')  
        
        

        for n=1:N
            for m=n+1:N
                Rvec[n,m,j]=(cor(out_trans[:,m],out_trans[:,n]))
                Rvec[m,n,j]=Rvec[n,m,j];
            end
        end

        BOLD_out[:,:,j] = out

    end

    return BOLD_out

end


