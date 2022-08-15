function setup(nWindows,tWindows,nTrials,nP;parallel="off",delays="on",plasticity="on",mode="rest",ISP="off",WCpars = WCparams())
   #load data and make struct & dist matrices
   @unpack W, dist,lags, N,minSC,W_sum = nP
   println("setting up Wilson Cowan Model")

   # set run mode
   if lowercase(mode) == lowercase("rest")
      StimSwitcher = ["off"]
   elseif lowercase(mode) == lowercase("rest+stim")
      StimSwitcher = ["off","on"]
   elseif lowercase(mode) == lowercase("stim")
      StimSwitcher = ["on"]
   end
   
   #set stimlation options
   stimOpt = "off"
   stimStr = -1.
   stimWindow = 2
   stimNodes = [39]
   Tstim = [30,60]

   #set plasticity options
   adapt="off"
   start_adapt=5
   LR=0.01
   if lowercase(plasticity) == "on" && nWindows > 5
      nSave = Int((nWindows-(start_adapt-1))*10*tWindows) + 2
   else 
      nSave = 2
   end
   
   # set ISP options
   if ISP == "on"
      WCp = WCpars
   else
      WCp= WCpars
   end

   #initialise dynamic synaptic weights
   cEEv = ones(N)*WCp.cEE
   cIEv = ones(N)*WCp.cIE
   cEIv = ones(N)*WCp.cEI
   cIIv = ones(N)*WCp.cII
   cSUM = cEEv[1]+cIEv[1]+cEIv[1]+cIIv[1]


   weights = Weights(cEEv,cIEv,cEIv,cIIv,cSUM)

   #initialise BOLD output array
   BOLD_saveat = collect(0:1.6:tWindows)
   size_out = length(BOLD_saveat)
   BOLD_TRIALS = zeros(N,nWindows*size_out,nTrials)
   if parallel == "on"
      BOLD_TRIALS = SharedArray(BOLD_TRIALS)
   end

   
   WHISTMAT = zeros(N,N)
   d=zeros(N)
   ONES=ones(N)
   nRuns=1

   #initialise array for saving synaptic weights
   wS =  weightsSave(zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),1)
   if ISP == "off"
      IC =  init(rand(3N))
   else
      IC = init(rand(4N))
   end
   bP = balloonModelParameters()

   
   timer = TimerStruct(0.,0.,0.)

  


   stimOpts = StimOptions(stimOpt,stimWindow,stimNodes,stimStr,Tstim)
   runOpts = RunOptions(tWindows,nWindows,StimSwitcher)
   solverOpts =  SolverOptions(delays,plasticity,adapt,ISP)
   runPars = RunParameters(0,WHISTMAT,d)
   adaptPars = adaptParameters(LR,start_adapt,10.01,IC.u0[1:N])
   
   solverStruct = WilsonCowanSolverStruct(WCp,nP,bP,IC,weights,wS,stimOpts,runOpts,solverOpts,runPars,adaptPars,nRuns,timer)

   return BOLD_TRIALS,solverStruct
end


