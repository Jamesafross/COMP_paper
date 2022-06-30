function run_nextgen()
    

    IC.u0 = make_init_conds(NGp,nP.N)  + 0.1*rand(8*nP.N)

    for setstim in ss
        nP.W .= SC
        κS.κSEEv = ones(nP.N)*NGp.κSEE
        κS.κSIEv = ones(nP.N)*NGp.κSIE
        κS.κSEIv = ones(nP.N)*NGp.κSEI
        κS.κSIIv = ones(nP.N)*NGp.κSII
        κS.κSUM  = κS.κSEEv[1]+κS.κSIEv[1]+κS.κSEIv[1]+κS.κSIIv[1]
        IC.u0 = make_init_conds(NGp,N)  + 0.1*rand(8N)
        
        
        wS.κSEEv[:,1] = κS.κSEEv
        wS.κSIEv[:,1] = κS.κSIEv
        wS.κSEIv[:,1] = κS.κSEIv
        wS.κSIIv[:,1] = κS.κSIIv
        wS.count = 2
        
        global opts.stimOpt = setstim

        println("Running model ... ")
        @time out = nextgen_model_windows_run()

        BOLD_OUT=[]
        for ii = 1:opts.nWindows
                if ii == 1
                    BOLD_OUT= out[:,:,ii]
                else
                    BOLD_OUT = cat(BOLD_OUT,out[:,:,ii],dims=2)
                end
        end


        if opts.stimOpt == "off"
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