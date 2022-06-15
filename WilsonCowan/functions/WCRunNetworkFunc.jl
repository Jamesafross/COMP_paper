function run_wilsoncowan()
    if parallel == "on"
        @sync @distributed for i = 1:nTrials
            println("working on Trial: ",i)
            BOLD = WCRun()
        end
    else
        for i = 1:nTrials
        println("working on Trial: ",i)
        out =  WCRun()
        BOLD_OUT=[]
        for ii = 1:nWindows
            if ii == 1
                BOLD_OUT= out[:,:,ii]
            else
                BOLD_OUT = cat(BOLD_OUT,out[:,:,ii],dims=2)
            end
        end
    
        global BOLD_TRIALS[:,:,i] = BOLD_OUT
    
        end    
end