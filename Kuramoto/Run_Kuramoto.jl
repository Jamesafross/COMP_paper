include("./setup.jl")

 

nTrials = 10
BOLD_OUT = zeros(N,size_out*nWindows)
BOLD_TRIAL_MEAN = zeros(N,size_out*nWindows)

for n = 1:nTrials
    IC.u0 = 0.18randn(N)
    
    out = KuramotoRun()

    for ii = 1:nWindows
        BOLD_OUT[:,1+size_out*(ii-1):ii*size_out]= out[:,:,ii] 
    end

    BOLD_TRIAL_MEAN += BOLD_OUT/nTrials

    
end




savedir = "Run_1"


save("$OutDATADIR/$savedir/BOLD_Kuramoto.jld","BOLD_Kuramoto",BOLD_TRIAL_MEAN)






