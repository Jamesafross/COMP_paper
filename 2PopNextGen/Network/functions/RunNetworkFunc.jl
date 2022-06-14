function Run_NextGen()
    
    Run_vec = LinRange(1,nRuns,nRuns)

    for jj = 1:length(Run_vec)
    
        IC.u0 = makeInitConds(NGp,nP.N)  + 0.1*rand(8*nP.N)

        for setstim in ss
            Run = string(Int(round(Run_vec[jj])))
            nP.W .= SC
            κS.κSEEv = ones(nP.N)*NGp.κSEE
            κS.κSIEv = ones(nP.N)*NGp.κSIE
            κS.κSEIv = ones(nP.N)*NGp.κSEI
            κS.κSIIv = ones(nP.N)*NGp.κSII
            κS.κSUM = κS.κSEEv[1]+κS.κSIEv[1]+κS.κSEIv[1]+κS.κSIIv[1]
            IC.u0 = init0
            
            
            wS.κSEEv[:,1] = κS.κSEEv
            wS.κSIEv[:,1] = κS.κSIEv
            wS.κSEIv[:,1] = κS.κSEIv
            wS.κSIIv[:,1] = κS.κSIIv
            wS.count = 2
            
            global opts.stimOpt = setstim

            println("Running model ... ")
            @time out,weightSaved = NGModelRun(timer)

            BOLD_OUT=[]
            for ii = 1:opts.nWindows
                    if ii == 1
                        BOLD_OUT= out[:,:,ii]
                    else
                        BOLD_OUT = cat(BOLD_OUT,out[:,:,ii],dims=2)
                    end
            end


            if opts.stimOpt == "on"
                save1 = "stim"
            else
                save1="NOstim"
            end
        
            
            run = "_Run_$Run_vec[jj]"
            kappa = "_kappa=$(NGp.κ)"
            etaE = "etaE=$(NGp.η_0E)"
            savename = save1*run*kappa*etaE
            dir0 = "LR_"
            dir1 = string(LR)
            dir2 = "_StimStr_"
            dir3 = string(opts.stimStr)

            savedir = dir0*dir1*dir2*dir3


            if save_data =="true"
                save("$OutDATADIR/$savedir/BOLD_$savename.jld","BOLD_$savename",BOLD_OUT)
                save("$OutDATADIR/$savedir/weights_$savename.jld","weights_$savename",weightSaved)
            end


        end

    end

end