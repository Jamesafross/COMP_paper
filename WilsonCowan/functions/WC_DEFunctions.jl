function WC(du,u,h,p,t)
    hparams = p
    @unpack WCp,nP,bP,IC,weights,wS,stimOpts,runOpts,solverOpts,runPars,adaptPars,nRuns,timer = solverStruct
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ = WCp
    @unpack W,lags,N = nP
    @unpack W, dist,lags,N,minSC,W_sum = nP
    @unpack stimOpt,stimWindow,stimNodes,stimStr,Tstim = stimOpts
    @unpack StimSwitcher,tWindows,nWindows = runOpts
    @unpack delays,plasticity,adapt = solverOpts
    @unpack counter,WHISTMAT,d = runPars

    @unpack W,lags,N = nP
    @unpack LearningRate,tP,HIST = adaptPars

    make_hist_mat2_threads!(h,W,u,hparams,N,lags,t,WHISTMAT)
    
    sum!(d,WHISTMAT)

    @inbounds Threads.@threads for i = 1:N

        E = u[i]
        I = u[i+N]

        if  t >= tP && adapt == "on"
              
            solverStruct.weights.cEEv[i],solverStruct.weights.cIEv[i],solverStruct.weights.cEIv[i],solverStruct.weights.cIIv[i] = adapt_local_func(h,hparams,t,weights,WCp,E,I,i,N,LearningRate)

            if i == N    
                #if mod(runPars.counter,10) == 0
                    
                 #   solverStruct.wS.cEEv[:,wS.count] = weights.cEEv
                  #  solverStruct.wS.cIEv[:,wS.count] = weights.cIEv
                   # solverStruct.wS.cEIv[:,wS.count] = weights.cEIv
                    #solverStruct.wS.cIIv[:,wS.count] = weights.cIIv
                    #solverStruct.wS.count += 1
                #end
                #nP.W = adapt_global_coupling(hparams,N,W,lags,h,t,u,minSC,W_sum)
                #solverStruct.adaptPars.tP += 0.01  
                #solverStruct.adaptPars.tP = round(adaptPars.tP,digits=2)
                #solverStruct.runPars.counter += 1
            end
        end
        #println(d)

        du[i] = (1/τE)*(-E + f(cEE*E + stim(t,i,stimNodes,Tstim,nWindow,stimOpt,stimWindow,stimStr)+  cIE*I + u[i+2N]+Pext + (η)*d[i],β,θE))
        du[i+N] =(1/τI)*( -I + f(cEI*E + cII*I+u[i+2N],β,θI) )
        du[i+2N] = (-1/τx)*u[i+2N]
    end
end

function dW(du,u,h,p,t)
    @unpack WCp,nP= solverStruct
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,η,σ = WCp
    @unpack W,lags,N = nP
    for i = 1:N
        du[i+2N] = σ
    end
end

function WC_ISP(du,u,h,p,t)
    hparams = p
    @unpack WCp,nP,bP,IC,weights,wS,stimOpts,runOpts,solverOpts,runPars,adaptPars,nRuns,timer = solverStruct
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ,Pext,τISP,ρ= WCp
    @unpack W,lags,N = nP
    @unpack W, dist,lags,N,minSC,W_sum = nP
    @unpack stimOpt,stimWindow,stimNodes,stimStr,Tstim = stimOpts
    @unpack StimSwitcher,tWindows,nWindows = runOpts
    @unpack delays,plasticity,adapt = solverOpts
    @unpack counter,WHISTMAT,d = runPars

    @unpack W,lags,N = nP
    @unpack LearningRate,tP,HIST = adaptPars

    make_hist_mat2_threads!(h,W,u,hparams,N,lags,t,WHISTMAT)
    
    sum!(d,WHISTMAT)

  
    @inbounds Threads.@threads for i = 1:N
   
        #println(d)
        E = u[i]
        I = u[i+N]
        du[i] = (1/τE)*(-E + f(cEE*E  + u[i+2*N]*I + u[i+3N]+Pext + (η)*d[i],β,θE))
        du[i+N] =(1/τI)*( -I + f(cEI*E + cII*I+u[i+3N],β,θI) )
        du[i+2N] = (1/τISP)*I*(E - ρ)
        du[i+3N] = (-1/τx)*u[i+3N]
    end
end

function dW_ISP(du,u,h,p,t)
    hparams = p
    @unpack WCp,nP= solverStruct
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ,Pext,τISP,ρ= WCp
    @unpack W,lags,N = nP
    for i = 1:N
        du[i+3N] = σ
    end
end


