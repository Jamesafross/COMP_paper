function nextgen_model_windows_run(solverStruct)
   @unpack NGp,nP,bP,IC,κS,wS,stimOpts,runOpts,solverOpts,runPars,adaptPars,nRuns,timer = solverStruct
   @unpack W, dist,lags,N,minSC,W_sum = nP
   @unpack stimOpt,stimWindow,stimNodes,stimStr,Tstim = stimOpts
   @unpack StimSwitcher,tWindows,nWindows = runOpts
   @unpack delays,plasticity,adapt,synapses = solverOpts
   @unpack LearningRate,windowStart,tP,HIST = adaptPars
   println("κ = ", solverStruct.NGp.κ)
   
 
    BOLD_saveat = collect(0:1.0:tWindows)
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
            solverStruct.IC.u0 = sol[:,end]
            iStart = findfirst(sol.t .> tWindows - 1.1)
            u_hist = make_uhist(sol.t[iStart:end] .- sol.t[end],sol[1:2N,iStart:end])
            hparams = u_hist
            solverStruct.runPars.tPrev = 0.0 
            solverStruct.runPars.timeAdapt = 0.01
            solverStruct.runPars.counter = 0 
            solverStruct.adaptPars.tP = 0.01
        end

        if plasticity == "on"
            if j < windowStart
                global solverStruct.solverOpts.adapt = "off"
            else
                global solverStruct.solverOpts.adapt = "on"
            end
        end
       
        tspan = (0.0,tWindows)
        adpStops = collect(0.01:0.01:tWindows)
      
    
       
        probDDE = nextgen


        if j == 1

                p = hparams,solverStruct
                alg = RKMil()
                prob = SDDEProblem(probDDE,dW,solverStruct.IC.u0, h1, tspan, p)
            global sol = solve(prob,alg,maxiters = 1e20,tstops=adpStops)
        else
            p = hparams,solverStruct
            alg = RKMil()
            prob = SDDEProblem(probDDE,dW,solverStruct.IC.u0, h2, tspan, p)
    
            tic1 = time()
            global sol = solve(prob,alg,maxiters = 1e20,tstops=adpStops)
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

    
        BalloonIn= make_In(sol.t,Current)
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

    return BOLD_out


end