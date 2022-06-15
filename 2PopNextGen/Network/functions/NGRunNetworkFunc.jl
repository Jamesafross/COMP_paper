function run_nextgen()
    
    Run_vec = LinRange(1,nRuns,nRuns)

    for jj = 1:length(Run_vec)
    
        IC.u0 = make_init_conds(NGp,nP.N)  + 0.1*rand(8*nP.N)

        for setstim in ss
            Run = string(Int(round(Run_vec[jj])))
            nP.W .= SC
            κS.κSEEv = ones(nP.N)*NGp.κSEE
            κS.κSIEv = ones(nP.N)*NGp.κSIE
            κS.κSEIv = ones(nP.N)*NGp.κSEI
            κS.κSIIv = ones(nP.N)*NGp.κSII
            κS.κSUM = κS.κSEEv[1]+κS.κSIEv[1]+κS.κSEIv[1]+κS.κSIIv[1]
            IC.u0 = make_init_conds(NGp,N)  + 0.1*rand(8N)
            
            
            wS.κSEEv[:,1] = κS.κSEEv
            wS.κSIEv[:,1] = κS.κSIEv
            wS.κSEIv[:,1] = κS.κSEIv
            wS.κSIIv[:,1] = κS.κSIIv
            wS.count = 2
            
            global opts.stimOpt = setstim

            println("Running model ... ")
            @time out,weightSaved = nextgen_model_windows_run()

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
        
            
            run = "_Run_$(Run_vec[jj])"
            kappa = "_kappa=$(NGp.κ)"
            etaE = "etaE=$(NGp.η_0E)"
            
            dir0 = "LR_"
            dir1 = string(LR)
            dir2 = "_StimStr_"
            dir3 = string(opts.stimStr)

            savename = run*kappa*etaE*dir0*dir1*dir2*dir3

            savedir = dir0*dir1*dir2*dir3


            if save_data == "true"
                println("saving BOLD data and synaptic weights")
                save("$OutDATADIR/BOLD/BOLD_$savename.jld","BOLD_$savename",BOLD_OUT)
                save("$OutDATADIR/weights/weights_$savename.jld","weights_$savename",weightSaved)
            end


        end

    end

end