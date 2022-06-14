function setup(numThreads,nWindows,tWindows;plasticityOpt="on",mode="rest",n_Runs=1,eta_0E = -14.19,kappa=0.505)

    plot_fit = "false"
    save_data = "true"

    W=zeros(N,N)
    W.=SC


    if lowercase(mode) == lowercase("rest")
        ss = ["off"]
    elseif lowercase(mode) == lowercase("rest+stim")
        ss=["off","on"]
    elseif lowercase(mode) == lowercase("stim")
        ss=["on"]
    end

    stimNodes = [39]
    Tstim = [60,90]

    #load data and make struct & dist matrices
    nWindows = 10
    tWindows = 100.0
    stimOpt = "off"
    stimStr = -5.
    stimWindow = 20
    plasticity=plasticityOpt
    adapt = "off"
    synapses = "1stOrder"

    NGp = NextGen2PopParams2()
    start_adapt = 5
    nSave = Int((nWindows-(start_adapt-1))*10*tWindows) + 2
    
    κSEEv = ones(N)*NGp.κSEE
    κSIEv = ones(N)*NGp.κSIE
    κSEIv = ones(N)*NGp.κSEI
    κSIIv = ones(N)*NGp.κSII
    κSUM = κSEEv[1]+κSIEv[1]+κSEIv[1]+κSIIv[1]

    init0 = makeInitConds(NGp,N)  + 0.1*rand(8N)

    nP = networkParameters(W, dist,lags, N, minSC,W_sum)
    bP = ballonModelParameters()
    LR = 0.01 # learning rate adaptation
    IC =  init(init0)
    κS = weights(κSEEv, κSIEv, κSEIv, κSIIv, κSUM )
    wS = weightSave(zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),1)
    opts=solverOpts(stimOpt,stimWindow,stimNodes,stimStr,Tstim,plasticity,adapt,synapses,tWindows,nWindows)
    vP = variousPars(0.0, 100.0,0)
    aP = adaptParams(10.01,IC.u0[1:N])
    HISTMAT = zeros(N,N)
    d = zeros(N)
    nRuns = n_Runs

    

    timer = Timer(0.,0.,0.)

    return plot_fit,save_data,NGp,start_adapt,init0,nP,bP,LR,IC,κS,wS,opts,vP,aP,HISTMAT,d,nRuns,timer

end

