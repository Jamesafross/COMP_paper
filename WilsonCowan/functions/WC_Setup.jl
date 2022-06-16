function setup(numThreads,nWindows,tWindows,nTrials;plasticityOpt="on",mode="rest")
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
   stimWindow = 2
   stimNodes = [39]
   Tstim = [30,60]
   adapt = "off"
   ISP = "off"
   start_adapt=5
   

   IC =  init(rand(3N))
   opts = solverOpts(stimOpt,stimWindow,stimNodes,Tstim,adapt,tWindows,nWindows,ISP)
   nP = networkParameters(W, dist,lags, N,minSC,W_sum)
   vP = variousPars(0.0, 50.0)
   bP = ballonModelParameters()
   LR=0.01
   timer = Timer(0.,0.,0.)

   if opts.ISP == "on"
      WCp = WCparamsISP()
   else
      WCp= WCparams()
   end

   BOLD_saveat = collect(0:1.6:tWindows)
   size_out = length(BOLD_saveat)
   BOLD_TRIALS = zeros(N,nWindows*size_out,nTrials)
   HISTMAT = zeros(N,N)
   d=zeros(N)
   ONES=ones(N)
   

   return plot_fit,save_data,BOLD_TRIALS,ss,WCp,vP,start_adapt,nP,bP,LR,IC,opts,HISTMAT,d,timer,ONES
end


