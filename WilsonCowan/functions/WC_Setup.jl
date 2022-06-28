function setup(numThreads,nWindows,tWindows,nTrials;delays="on",plasticityOpt="on",mode="rest")
   #load data and make struct & dist matrices

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

   
   stimOpt = "off"
   stimStr = -1.
   stimWindow = 2
   stimNodes = [39]
   Tstim = [30,60]
   adapt="off"
   ISP = "off"
   start_adapt=5


   if lowercase(plasticityOpt) == "on"
      nSave = Int((nWindows-(start_adapt-1))*10*tWindows) + 2
   else 
      nSave = 2
   end

   if ISP == "on"
      WCp = WCparamsISP()
   else
      WCp= WCparams()
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
   nP = networkParameters(W, dist,lags, N,minSC,W_sum)
   vP = variousPars(0.0, 50.0,0)
   bP = ballonModelParameters()
   LR=0.01
   timer = Timer(0.,0.,0.)

  

   BOLD_saveat = collect(0:1.6:tWindows)
   size_out = length(BOLD_saveat)
   BOLD_TRIALS = zeros(N,nWindows*size_out,nTrials)
   HISTMAT = zeros(N,N)
   d=zeros(N)
   ONES=ones(N)
   

   return BOLD_TRIALS,ss,WCp,vP,start_adapt,nP,bP,LR,IC,weights,wS,opts,HISTMAT,d,timer,ONES
end


