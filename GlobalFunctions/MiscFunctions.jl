function normalise(W,N)
    for ii = 1:N
     W[W .< 0.0] .= 0.0
         if sum(W[:,ii]) != 0.0
         @views W[:,ii] = W[:,ii]./sum(W[:,ii])
         end
 
     end
      @inbounds for k=1:N #Maintaining symmetry in the weights between regions
         @inbounds for l = k:N
                  W[k,l] = (W[k,l]+W[l,k])/2
                  W[l,k] = W[k,l]
         end
     end
     return W
 end

