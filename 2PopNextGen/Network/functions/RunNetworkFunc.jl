function Run_NextGen(numThreads,nWindows,tWindows;plasticity="on",mode="rest",nRuns=1,eta_0E = -14.19,kappa=0.505)
    workdir = "$(homedir())/COMP_paper/2PopNextGen/Network"
    include("$workdir/setup.jl")
    LinearAlgebra.BLAS.set_num_threads(numThreads)

    NGp.η_0E = eta_0E
    NGp.κ = kappa
    opts.nWindows=nWindows
    opts.tWindows=tWindows

    if mode == lowercase("rest")
        ss = ["off"]
    elseif mode == lowercase("rest+stim")
        ss=["off","on"]
    elseif mode == lowercase("stim")
        ss=["on"]
    end

    if plasticity==lowercase("on") 
        opts.adapt="on"
    else
        opts.adapt="off"
    end
    




    Run_vec = LinRange(1,nRuns,nRuns)

    for jj = 1:length(Run_vec)
    
        IC.u0 = makeInitConds(NGp,N)  + 0.1*rand(8N)

        for setstim in ss
            Run = string(Int(round(Run_vec[jj])))
            nP.W .= SC
            κS.κSEEv = ones(N)*NGp.κSEE
            κS.κSIEv = ones(N)*NGp.κSIE
            κS.κSEIv = ones(N)*NGp.κSEI
            κS.κSIIv = ones(N)*NGp.κSII
            κS.κSUM = κSEEv[1]+κSIEv[1]+κSEIv[1]+κSIIv[1]
            IC.u0 = init0
            
            
            wS.κSEEv[:,1] = κSEEv
            wS.κSIEv[:,1] = κSIEv
            wS.κSEIv[:,1] = κSEIv
            wS.κSIIv[:,1] = κSIIv
            wS.count = 2
            
            global opts.stimOpt = setstim

            println("Running model ... ")
            @time out,weightSaved = NGModelRun(κS,wS,start_adapt)

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
            etaE = "etaE=$(NGp.η_E0)"
            savename = save1*run*kappa*etaE
            dir0 = "LR_"
            dir1 = string(LR)
            dir2 = "_StimStr_"
            dir3 = string(stimStr)

            savedir = dir0*dir1*dir2*dir3


            if save_data =="true"
                save("$OutDATADIR/$savedir/BOLD_$savename.jld","BOLD_$savename",BOLD_OUT)
                save("$OutDATADIR/$savedir/weights_$savename.jld","weights_$savename",weightSaved)
            end


        end

    end

end