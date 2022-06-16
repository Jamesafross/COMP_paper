
function KuramotoRun()
    @unpack W, dist,lags,N,minSC,W_sum = nP
    @unpack tWindows,nWindows = opts
     
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
             u_hist = make_uhist(sol.t[iStart:end] .- sol.t[end],sol[1:N,iStart:end])
             hparams = u_hist
         end
 
        
         tspan = (0.0,tWindows)
    
     
         global p = hparams
 
         if j == 1
            prob = SDDEProblem(Kuramoto,dW,IC.u0, h1, tspan, p)
            @time global sol = solve(prob,EM(),dt=0.01,maxiters = 1e20,reltol=0)
         else
            prob = SDDEProblem(Kuramoto,dW,IC.u0, h2, tspan, p)
            @time global sol = solve(prob,EM(),dt=0.01,maxiters = 1e20,reltol=0)
         end
       
         sol1 = cos.(sol)
         BalloonIn= make_In(sol.t,sol1)
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

     println(size(BOLD_out))
 
     return BOLD_out
end