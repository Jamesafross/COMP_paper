function networksetup(c;digits=3,type_SC="paulData",N=2,density=1,normalise=false)
    if lowercase(type_SC) == lowercase("paulData")
        SC_Array,FC_Array,dist = getData_nonaveraged(;SCtype="log")
        FC_Array = FC_Array
        PaulFCmean = mean(FC_Array,dims=3)
        lags = dist./c
        lags = round.(lags,digits=digits) 
        #lags[lags.<0.003] .= 0.000
        #lags[SC .< 0.018] .= 0  
        if normalise == false
            SC = 0.01SC_Array[:,:,1]
        else
            SC = SC_Array[:,:,1]
            SC = SC/maximum(SC)
        end
        minSC,W_sum=getMinSC_and_Wsum(SC)
        N = size(SC,1)
        return SC,dist,lags,N,minSC,W_sum,FC_Array
    elseif lowercase(type_SC) == lowercase("generated")
        
        SC,lags = generate_network_matrices(N;density=density)
        
        dist = lags
        minSC,W_sum=getMinSC_and_Wsum(SC)
        N = size(SC,1)
        return SC,dist,lags,N,minSC,W_sum

    end
    
    
end