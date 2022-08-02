function run_nextgen()
    @unpack NGp,nP,bP,IC,κS,wS,stimOpts,runOpts,solverOpts,runPars,adaptPars,nRuns,timer = solverStruct
   
    

    for setstim in runOpts.StimSwitcher
        nP.W .= SC
        solverStruct.κS.κSEEv = ones(nP.N)*NGp.κSEE
        solverStruct.κS.κSIEv = ones(nP.N)*NGp.κSIE
        solverStruct.κS.κSEIv = ones(nP.N)*NGp.κSEI
        solverStruct.κS.κSIIv = ones(nP.N)*NGp.κSII
        solverStruct.κS.κSUM  = κS.κSEEv[1]+κS.κSIEv[1]+κS.κSEIv[1]+κS.κSIIv[1]
        solverStruct.IC.u0 = round.(make_init_conds(NGp,N),digits=4) 
        
        
        solverStruct.wS.κSEEv[:,1] = solverStruct.κS.κSEEv
        solverStruct.wS.κSIEv[:,1] = solverStruct.κS.κSIEv
        solverStruct.wS.κSEIv[:,1] = solverStruct.κS.κSEIv
        solverStruct.wS.κSIIv[:,1] = solverStruct.κS.κSIIv
        solverStruct.wS.count = 2
        
        solverStruct.stimOpts.stimOpt = setstim

        println("Running model ... ")
        @time out = nextgen_model_windows_run()

        BOLD_OUT=[]
        for ii = 1:runOpts.nWindows
                if ii == 1
                    BOLD_OUT= out[:,:,ii]
                else
                    BOLD_OUT = cat(BOLD_OUT,out[:,:,ii],dims=2)
                end
        end


        if stimOpts.stimOpt == "off"
            save1 = "NOstim"
            global BOLD_REST= NextGenSol_rest(BOLD_OUT)
        else
            save1="stim"
            global BOLD_STIM = NextGenSol_stim(BOLD_OUT)
        end
    
        
    


       




    end
    if lowercase(mode) == "rest"
        global BOLD = BOLD_REST
    elseif lowercase(mode) == "stim"
        global BOLD = BOLD_STIM
    elseif lowercase(mode) == "rest+stim"
        global BOLD = NextGenSol_reststim(BOLD_REST.BOLD_rest,BOLD_STIM.BOLD_stim)
    end

end