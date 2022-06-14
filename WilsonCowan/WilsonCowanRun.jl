parallel = "off"


if parallel == "on"
    include("setupDistributed.jl")
else
    include("setup.jl")
end

if parallel == "on"

    @sync @distributed for i = 1:nTrials
        println("working on Trial: ",i)
        BOLD = WCRun(WCp,bP)
    end
else
    for i = 1:nTrials
    println("working on Trial: ",i)
    out =  WCRun(WCp,bP)
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






    
