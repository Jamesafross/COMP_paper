#################################
# Functions for use in the DDE  #
# solver                        #
#################################
function nextgen_vec(du,u,h,p,t)
    hparams = p
    @unpack ΔE,ΔI,η_0E,η_0I,τE,τI,αEE,αIE,αEI,αII,κSEE,κSIE,κSEI,
    κSII,κVEE,κVIE,κVEI,κVII,VsynEE,VsynIE,VsynEI,VsynII,κ = NGp
    @unpack κSEEv,κSIEv,κSEIv,κSIIv,κSUM = κS
    @unpack tPrev,timeAdapt,count = vP
    @unpack stimOpt,stimWindow,stimNodes,stimStr,Tstim,adapt,synapses,tWindows,nWindows = opts
    @unpack W,dist,lags,N,minSC,W_sum = nP
    @unpack tP,HIST = aP 

    make_hist_mat2!(h,W,u,hparams,N,lags,t,WHISTMAT)
    mul!(d,WHISTMAT,ONES)

    @views rE=u[1:N]
    @views rI=u[N+1:2N]
    @views vE=u[2N+1:3N]
    @views vI=u[3N+1:4N]
    @views gEE=u[4N+1:5N]
    @views gIE=u[5N+1:6N]
    @views gEI=u[6N+1:7N]
    @views gII=u[7N+1:8N]
    
    @inbounds Threads.@threads for i = 1:N
       

       

        if  t >= tP && adapt == "on"
        
            
        κS.κSEEv[i],κS.κSIEv[i],κS.κSEIv[i],κS.κSIIv[i] = adapt_local_func(h,hparams,t,κS,NGp,u[i],u[i+N],i,N,LR)
        if i == N
            
            if mod(vP.count,10) == 0
                
                wS.κSEEv[:,wS.count] = κS.κSEEv
                wS.κSIEv[:,wS.count] = κS.κSIEv
                wS.κSEIv[:,wS.count] = κS.κSEIv
                wS.κSIIv[:,wS.count] = κS.κSIIv
                wS.count += 1
            end
            #nP.W = adapt_global_coupling(hparams,N,W,lags,h,t,u,minSC,W_sum)
            aP.tP += 0.01  
            aP.tP = round(aP.tP,digits=2)
            vP.count += 1
        end
    end
        
        
        
     
  
  
      end

         #rE
         @. du[1:N] =(1. /τE)*(-gEE*rE -gEI*rE - κVEE*rE - κVEI*rE +2. * rE * vE + (ΔE / (τE*pi)))
         #rI
         @. du[N+1:2N] =(1. /τI)*(-gIE*rI - gII*rI -κVIE*rI - κVII*rI + 2. * rI * vI + (ΔI / (τI*pi)))
         #vE
         @. du[2N+1:3N] =(1. /τE)*(gEE*(VsynEE - vE) + gEI*(VsynEI - vI) + κVEI*(vI - vE) - (τE^2)*(pi^2) * (rE^2.) +  vE^2. + η_0E)
         #vI
         @. du[3N+1:4N] =(1. /τI)*(gIE*(VsynIE - vE) + gII*(VsynII - vI) + κVIE*(vE - vI) - (τI^2)*(pi^2)* (rI^2.) + vI^2. + η_0I)
         #gEE
         @. du[4N+1:5N] = αEE * (-gEE + κ*d + κSEEv*rE)
         #gIE
         @. du[5N+1:6N] = αIE * (-gIE + κSIEv * rE)
         #gEI
         @. du[6N+1:7N] = αEI * (-gEI + κSEIv * rI)
         #gII
         @. du[7N+1:8N] = αII * (-gII + κSIIv * rI)
  
  end


  function nextgen(du,u,h,p,t)
    hparams = p
    @unpack ΔE,ΔI,η_0E,η_0I,τE,τI,αEE,αIE,αEI,αII,κSEE,κSIE,κSEI,
    κSII,κVEE,κVIE,κVEI,κVII,VsynEE,VsynIE,VsynEI,VsynII,κ = [1.,1.,1.,1.,1.,1.,1.,1.,1.,1,1.]
  

    make_hist_mat2!(h,W,u,hparams,N,lags,t,WHISTMAT)
    mul!(d,WHISTMAT,ONES)

    
    
    @inbounds Threads.@threads for i = 1:N

        rE=u[i]
        rI=u[i+N]
        vE=u[i+2N]
        vI=u[i+3N]
        gEE=u[i+4N]
        gIE=u[i+5N]
        gEI=u[i+6N]
        gII=u[i+7N]

       
        
        
        
        #rE
        du[i] =(1. /τE)*(-gEE*rE -gEI*rE - κVEE*rE - κVEI*rE +2. * rE * vE + (ΔE / (τE*pi)))
        #rI
        du[i+N] =(1. /τI)*(-gIE*rI - gII*rI -κVIE*rI - κVII*rI + 2. * rI * vI + (ΔI / (τI*pi)))
        #vE
        du[i+2N] =(1. /τE)*(gEE*(VsynEE - vE) + gEI*(VsynEI - vI) + κVEI*(vI - vE) - (τE^2)*(pi^2) * (rE^2.) +  vE^2. + η_0E +stim(t,i,stimNodes,Tstim,nWindow,stimOpt,stimWindow,stimStr))
        #vI
        du[i+3N] =(1. /τI)*(gIE*(VsynIE - vE) + gII*(VsynII - vI) + κVIE*(vE - vI) - (τI^2)*(pi^2)* (rI^2.) + vI^2. + η_0I)
        #gEE
        du[i+4N] = αEE * (-gEE + κ*d[i] + κSEEv*rE)
        #gIE
        du[i+5N] = αIE * (-gIE + κSIEv * rE)
        #gEI
        du[i+6N] = αEI * (-gEI + κSEIv * rI)
        #gII
        du[i+7N] = αII * (-gII + κSIIv * rI)
  
  
      end
  
  end

  function nextgen_nodelay(du,u,p,t)
   
    @unpack ΔE,ΔI,η_0E,η_0I,τE,τI,αEE,αIE,αEI,αII,κSEE,κSIE,κSEI,
    κSII,κVEE,κVIE,κVEI,κVII,VsynEE,VsynIE,VsynEI,VsynII,κ = NGp
    @unpack κSEEv,κSIEv,κSEIv,κSIIv,κSUM = κS
    @unpack tPrev,timeAdapt,count = vP
    @unpack stimOpt,stimWindow,stimNodes,stimStr,Tstim,adapt,synapses,tWindows,nWindows = opts
    @unpack W,dist,lags,N,minSC,W_sum = nP
    @unpack tP,HIST = aP 

    mul!(d,W,u[1:N])

    @inbounds for i = 1:N
       

        rE=u[i]
        rI=u[i+N]
        vE=u[i+2N]
        vI=u[i+3N]
        gEE=u[i+4N]
        gIE=u[i+5N]
        gEI=u[i+6N]
        gII=u[i+7N]

        if  t >= tP && adapt == "on"
        
            
        κS.κSEEv[i],κS.κSIEv[i],κS.κSEIv[i],κS.κSIIv[i] = adapt_local_func_nodelay(κS,NGp,rE,rI,i,LR)
            if i == N
                
                if mod(vP.count,10) == 0
                    wS.κSEEv[:,wS.count] = κS.κSEEv
                    wS.κSIEv[:,wS.count] = κS.κSIEv
                    wS.κSEIv[:,wS.count] = κS.κSEIv
                    wS.κSIIv[:,wS.count] = κS.κSIIv
                    wS.count += 1
                end

                #nP.W = adapt_global_coupling(hparams,N,W,lags,h,t,u,minSC,W_sum)
                aP.tP += 0.01  
                aP.tP = round(aP.tP,digits=2)
                vP.count += 1
            end
        end
        sum(A,B,dims=2);
        
        
        #rE
        du[i] =(1. /τE)*(-gEE*rE -gEI*rE - κVEE*rE - κVEI*rE +2. * rE * vE + (ΔE / (τE*pi)))
        #rI
        du[i+N] =(1. /τI)*(-gIE*rI - gII*rI -κVIE*rI - κVII*rI + 2. * rI * vI + (ΔI / (τI*pi)))
        #vE
        du[i+2N] =(1. /τE)*(gEE*(VsynEE - vE) + gEI*(VsynEI - vI) + κVEI*(vI - vE) - (τE^2)*(pi^2) * (rE^2.) +  vE^2. + η_0E + stim(t,i,stimNodes,Tstim,nWindow,stimOpt,stimWindow,stimStr))
        #vI
        du[i+3N] =(1. /τI)*(gIE*(VsynIE - vE) + gII*(VsynII - vI) + κVIE*(vE - vI) - (τI^2)*(pi^2)* (rI^2.) + vI^2. + η_0I)
        #gEE
        du[i+4N] = αEE * (-gEE + κ*d[i] + κSEEv[i]*rE)
        #gIE
        du[i+5N] = αIE * (-gIE + κSIEv[i] * rE)
        #gEI
        du[i+6N] = αEI * (-gEI + κSEIv[i] * rI)
        #gII
        du[i+7N] = αII * (-gII + κSIIv[i] * rI)
  
  
      end
  
  end


  function NextGen2ndOrderSynapses(du,u,h,p,t)
    NGp,nP,hparams= p
    ΔE,ΔI,η_0E,η_0I,τE,τI,αEE,αIE,αEI,αII,κSEE,κSIE,κSEI,
    κSII,κVEE,κVIE,κVEI,κVII,VsynEE,VsynIE,VsynEI,VsynII,κ = NGp
  
    W,lags,N = nP
  
 
    @inbounds for i = 1:N
        d = 0.0

        @inbounds for j = 1:N
            if W[i,j] != 0.
                if lags[i,j] == 0.
                    d  += W[i,j]*u[j]   
                else
                    d += W[i,j]*h(hparams,t-lags[i,j]; idxs=j)
                end
            end

        end

        rE=u[i]
        rI=u[i+N]
        vE=u[i+2N]
        vI=u[i+3N]
        gEE=u[i+4N]
        gIE=u[i+5N]
        gEI=u[i+6N]
        gII=u[i+7N]
        gext=u[i+8N]
        pEE=u[i+9N]
        pIE=u[i+10N]
        pEI=u[i+11N]
        pII=u[i+12N]
        pext=u[i+13N]
        
        #rE
        du[i] =(1. /τE)*(-rE*(gEE + gEI + gext + κVEE +  κVEI - 2 * vE) + (ΔE / (τE*pi)))
        #rI
        du[i+N] =(1. /τI)*(-rI*(gIE + gII + κVIE + κVII - 2 * vI) + (ΔI / (τI*pi)))
        #vE
        du[i+2N] =(1. /τE)*(gEE*(VsynEE - vE) + gext*(VsynEXT - vE) +  gEI*(VsynEI - vI) + κVEI*(vI - vE) - (τE^2)*(pi^2) * (rE^2.) +  vE^2. + η_0E)
        #vI
        du[i+3N] =(1. /τI)*(gIE*(VsynIE - vE) + gII*(VsynII - vI) + κVIE*(vE - vI) - (τI^2)*(pi^2)* (rI^2.) + vI^2. + η_0I)
        #gEE
        du[i+4N] = αEE * (-gEE + pEE)
        #gIE
        du[i+5N] = αIE * (-gIE + pIE)
        #gEI
        du[i+6N] = αEI * (-gEI + pEI)
        #gII
        du[i+7N] = αII * (-gII + pII)
        #gext
        du[i+8N] = αext * (-gext + pext)
        #pEE
        du[i+9N] = αEE * (-pEE + κSEE*rE)
        #pIE
        du[i+10N] = αIE * (-pIE + κSIE * rE)
        #pEI
        du[i+11N] = αEI * (-pEI + κSEI * rI)
        #pII
        du[i+12N] = αII * (-pII + κSII * rI)
        #pext
        du[i+13N] = αext * (-pext + κ*d)
        
      end
  end