function setup(numThreads,nWindows,tWindows;delays="on",plasticityOpt="on",mode="rest",n_Runs=1,eta_0E = -14.19,kappa=0.505)

    W=zeros(N,N)
    W.=SC


    if lowercase(mode) == "rest"
        ss = ["off"]
    elseif lowercase(mode) == "rest+stim"
        ss=["off","on"]
    elseif lowercase(mode) == "stim"
        ss=["on"]
    end

    stimNodes = [39]
    Tstim = [60,90]

    #load data and make struct & dist matrices
    stimOpt = "off"
    stimStr = -5.
    stimWindow = 20
    plasticity=plasticityOpt
    adapt = "off"
    synapses = "1stOrder"

    NGp = NextGen2PopParams2()
    start_adapt = 5
    if lowercase(plasticity) == "on"
        nSave = Int((nWindows-(start_adapt-1))*10*tWindows) + 2
    else 
        nSave = 2
    end
    
    κSEEv = ones(N)*NGp.κSEE
    κSIEv = ones(N)*NGp.κSIE
    κSEIv = ones(N)*NGp.κSEI
    κSIIv = ones(N)*NGp.κSII
    κSUM = κSEEv[1]+κSIEv[1]+κSEIv[1]+κSIIv[1]

    init0 = make_init_conds(NGp,N)  + 0.1*rand(8N)

    nP = networkParameters(W, dist,lags, N, minSC,W_sum)
    bP = ballonModelParameters()
    LR = 0.01 # learning rate adaptation
    IC =  init(init0)
    κS = weights(κSEEv, κSIEv, κSEIv, κSIIv, κSUM )
    wS = weightSave(zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),1)
    opts=solverOpts(delays,stimOpt,stimWindow,stimNodes,stimStr,Tstim,plasticity,adapt,synapses,tWindows,nWindows)
    vP = variousPars(0.0, 100.0,0)
    aP = adaptParams(10.01,IC.u0[1:N])
    WHISTMAT = zeros(N,N)
    d = zeros(N)
    nRuns = n_Runs
    ONES = ones(N)
    non_zero_weights = find_non_zero_weights(W)
    timer = Timer(0.,0.,0.)
    

    if lowercase(delays) == "on"
        deStr="delays"
    elseif lowercase(delays) == "off"
        deStr="no delays"
    end

    if lowercase(plasticity) == "on"
        pStr="plasticity"
    elseif lowercase(plasticity) == "off"
        pStr="plasticity"
    end



    println("Running Next-Gen model with ",deStr," and ",pStr," starting at Window ",start_adapt,".")

    return ss,NGp,start_adapt,nP,bP,LR,IC,κS,wS,opts,vP,aP,WHISTMAT,d,nRuns,timer,ONES,non_zero_weights

end
