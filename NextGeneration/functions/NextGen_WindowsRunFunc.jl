function nextgen_model_windows_run()
   @unpack W, dist,lags,N,minSC,W_sum = nP
   @unpack stimOpt,stimWindow,stimNodes,stimStr,Tstim,adapt,synapses,tWindows,nWindows = opts
    
    BOLD_saveat = collect(0:1.6:tWindows)
    size_out = length(BOLD_saveat)
    BOLD_out = zeros(N,size_out,nWindows)
       
    for j = 1:nWindows
        
        global nWindow = j
       
         
        if nWindows > 1
            println("working on window  : ",j)
        end

        if j == 1
            hparams = IC.u0
        else
            IC.u0 = sol[:,end]
            iStart = findfirst(sol.t .> tWindows - 1.1)
            rE0 = sol[1:N,:]
            u_hist = make_uhist(sol.t[iStart:end] .- sol.t[end],sol[1:2N,iStart:end])
            hparams = u_hist
            vP.tPrev = 0.0 
            vP.timeAdapt = 0.01
            vP.count = 0 
            aP.tP = 0.01
        end

        if opts.plasticity == "on"
            if j < start_adapt
                global opts.adapt = "off"
            else
                global opts.adapt = "on"
            end
        end
       
        tspan = (0.0,tWindows)
        adpStops = collect(0.01:0.01:tWindows)
        clags = cat(unique(reshape(lags[lags.>0.0],length(lags[lags.>0.0]))),1.0,dims=1)

    
        

        if lowercase(opts.delays) == "on"
            probDDE = nextgen
        elseif lowercase(opts.delays) == "off"
            probDDE = nextgen_nodelay
        end

        if j == 1
            if lowercase(opts.delays) == "on"
                p = hparams
                alg = MethodOfSteps(BS3())
                prob = DDEProblem(probDDE,IC.u0, h1, tspan, p)
            elseif lowercase(opts.delays)=="off"
                alg = BS3()
                prob = ODEProblem(probDDE,IC.u0, tspan)
            end

            global sol = solve(prob,alg,maxiters = 1e20,tstops=adpStops,saveat=0.01,reltol=1e-3,abstol=1e-6)
        else
            if lowercase(opts.delays) == "on"
                p = hparams
                alg = MethodOfSteps(BS3())
                prob = DDEProblem(probDDE,IC.u0, h2, tspan, p)
            elseif lowercase(opts.delays)=="off"
                alg = BS3()
                prob = ODEProblem(probDDE,IC.u0, tspan)
            end
            tic1 = time()
            global sol = solve(prob,alg,maxiters = 1e20,tstops=adpStops,saveat=0.01,reltol=1e-3,abstol=1e-6)
            global timer.meanIntegrationTime += (time() - tic1)/(nWindows-1)
        end
        vE = sol[2N+1:3N,:]
        vI = sol[3N+1:4N,:]
        gEE = sol[4N+1:5N,:]
        gIE = sol[5N+1:6N,:]
        gEI = sol[6N+1:7N,:]
        gII = sol[7N+1:8N,:]

       
        currentE =  (gEE.*(NGp.VsynEE .- vE) .+ gEI.*(NGp.VsynEI .- vE));
        currentI =  (gIE.*(NGp.VsynIE .- vI) .+ gII.*(NGp.VsynII .- vI));
        Current = currentE .+ currentI

    
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
        
          

       
        BOLD_out[:,:,j] = out

    end

    return BOLD_out,wS


end