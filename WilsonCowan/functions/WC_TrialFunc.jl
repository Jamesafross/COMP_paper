function WC_run_trials()
    for i = 1:nTrials
        println("working on Trial: ",i)
        out =  wilsoncowan_windows_run()
        BOLD_OUT=[]
        for ii = 1:nWindows
            if ii == 1
                BOLD_OUT= out[:,:,ii]
            else
                BOLD_OUT = cat(BOLD_OUT,out[:,:,ii],dims=2)
            end
        end
        BOLD_TRIALS[:,:,i] = BOLD_OUT
    end

    return BOLD_TRIALS
end