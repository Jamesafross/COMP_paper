function getFCwindows(SIG,N)
    FC = zeros(N,N)
        for ii = 1:N
            for jj = ii+1:N
                FC[ii,jj] = cor(SIG[ii,:],SIG[jj,:])
                FC[jj,ii] =  FC[ii,jj]
            end
        end
    return FC
end


function get_FC(BOLD)
    step_i = 20
    step_j = 300
    N = size(BOLD,1)
    counterT = 1

    for i = 1:step_i:size(BOLD,2)
        j = i + step_j
        if j < size(BOLD,2)
            counterT +=1
        else
            break
        end
    end



    MODEL_FC = zeros(N,N,counterT) 

   

  
    counter = 1
    for i = 1:step_i:size(BOLD,2)
        j = i + step_j
        if j < size(BOLD,2)
            MODEL_FC[:,:,counter] = getFCwindows(BOLD[:,i:j],N)
            counter += 1
            #println(counter)
          
        else
            break
        end
    end
    return MODE_FC[:,:,1:end-1]
end
