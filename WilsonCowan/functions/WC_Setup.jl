function setup(nWindows,tWindows,nTrials,nP,;parallel="off",delays="on",plasticityOpt="on",mode="rest",ISP="off",WCpars = WCparams())
   #load data and make struct & dist matrices
   @unpack W, dist,lags, N,minSC,W_sum = nP
   println("setting up Wilson Cowan Model")

   plot_fit = "false"
   save_data = "true"

  


   if lowercase(mode) == lowercase("rest")
      ss = ["off"]
   elseif lowercase(mode) == lowercase("rest+stim")
      ss=["off","on"]
   elseif lowercase(mode) == lowercase("stim")
      ss=["on"]
   end

   
   stimOpt = "off"
   stimStr = -1.
   stimWindow = 2
   stimNodes = [39]
   Tstim = [30,60]
   adapt="off"
   start_adapt=5


   if lowercase(plasticityOpt) == "on"
      nSave = Int((nWindows-(start_adapt-1))*10*tWindows) + 2
   else 
      nSave = 2
   end

   println(nSave)

   if ISP == "on"
      WCp = WCpars
   else
      WCp= WCpars
   end
   
   cEEv = ones(N)*WCp.cEE
   cIEv = ones(N)*WCp.cIE
   cEIv = ones(N)*WCp.cEI
   cIIv = ones(N)*WCp.cII
   cSUM = cEEv[1]+cIEv[1]+cEIv[1]+cIIv[1]

   weights = Weights(cEEv,cIEv,cEIv,cIIv,cSUM)
   wS =  weightsSave(zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),zeros(N,nSave),1)
   IC =  init(rand(3N))
   opts = solverOpts(delays,stimOpt,stimWindow,stimNodes,stimStr,Tstim,plasticityOpt,adapt,tWindows,nWindows,ISP)
   
   aP = adaptParams(10.01,IC.u0[1:N])
   vP = variousPars(0.0, 50.0,0)
   bP = ballonModelParameters()
   LR=0.01
   timer = Timer(0.,0.,0.)

  

   BOLD_saveat = collect(0:1.6:tWindows)
   size_out = length(BOLD_saveat)
   BOLD_TRIALS = zeros(N,nWindows*size_out,nTrials)
   if parallel == "on"
      BOLD_TRIALS = SharedArray(BOLD_TRIALS)
   end
   HISTMAT = zeros(N,N)
   d=zeros(N)
   ONES=ones(N)
   

   return BOLD_TRIALS,ss,WCp,vP,aP,start_adapt,nP,bP,LR,IC,weights,wS,opts,HISTMAT,d,timer,ONES
end


