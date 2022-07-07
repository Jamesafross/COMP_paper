function WC(du,u,h,p,t)
    hparams = p

    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ = WCp
    @unpack W,lags,N = nP
    @unpack tPrev,timeAdapt = vP
    @unpack delays,stimOpt,stimWindow,stimNodes,stimStr,Tstim,adapt,tWindows,nWindows,ISP = opts
    @unpack tP,HIST = aP 

    println(t)


    make_hist_mat2_threads!(h,W,u,hparams,N,lags,t,WHISTMAT)
    
    mul!(d,WHISTMAT,ONES)

    @inbounds Threads.@threads for i = 1:N

        E = u[i]
        I = u[i+N]

        if  t >= tP && adapt == "on"
              
            weights.cEEv[i],weights.cIEv[i],weights.cEIv[i],weights.cIIv[i] = adapt_local_func(h,hparams,t,weights,WCp,E,I,i,N,LR)

            if i == N    
                if mod(vP.count,10) == 0
                    
                    wS.cEEv[:,wS.count] = weights.cEEv
                    wS.cIEv[:,wS.count] = weights.cIEv
                    wS.cEIv[:,wS.count] = weights.cEIv
                    wS.cIIv[:,wS.count] = weights.cIIv
                    wS.count += 1
                end
                #nP.W = adapt_global_coupling(hparams,N,W,lags,h,t,u,minSC,W_sum)
                aP.tP += 0.01  
                aP.tP = round(aP.tP,digits=2)
                vP.count += 1
            end
        end
        #println(d)

        du[i] = (1/τE)*(-E + f(cEE*E + stim(t,i,stimNodes,Tstim,nWindow,stimOpt,stimWindow,stimStr)+  cIE*I + u[i+2N]+Pext + (η)*d[i],β,θE))
        du[i+N] =(1/τI)*( -I + f(cEI*E + cII*I+u[i+2N],β,θI) )
        du[i+2N] = (-1/τx)*u[i+2N]
    end
end

function dW(du,u,h,p,t)
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,η,σ = WCp
    @unpack W,lags,N = nP
    for i = 1:N
        du[i+2N] = σ
    end
end

function WC_ISP(du,u,h,p,t)
    hparams = p

    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ,τISP,ρ = WCp
    @unpack W,lags,N = nP
    @unpack stimOpt,adapt=opts
    @unpack tP,HIST = aP 

  
    @inbounds for i = 1:N
        d = 0.0
        @inbounds for j = 1:N
            if W[i,j] > 0.0
                if lags[i,j] > 0.0
                    d += W[i,j]*h(hparams,t-lags[i,j],idxs=j)
              
                else
                    d += W[i,j]*u[j]
                end
            end
        end
        #println(d)
        E = u[i]
        I = u[i+N]
        du[i] = (1/τE)*(-E + f(cEE*E + stim(t,i,stimNodes,Tstim,nRun,stimOpt) + u[i+2N]*I + u[i+3N]+Pext + (η)*d,β,θE))
        du[i+N] =(1/τI)*( -I + f(cEI*E + cII*I+u[i+3N],β,θI) )
        du[i+2N] = (1/τISP)*I*(E - ρ)
        du[i+3N] = (-1/τx)*u[i+3N]
    end
end

function dW_ISP(du,u,h,p,t)
    hparams = p
    @unpack cEE,cEI,cIE,cII,τE,τI,τx,Pext,θE,θI,β,η,σ,τISP,ρ = WCp
    @unpack W,lags,N = nP
    for i = 1:N
        du[i+3N] = σ
    end
end


