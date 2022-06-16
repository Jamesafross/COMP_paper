mutable struct Timer
    meanIntegrationTime
    meanBalloonTime
    meanAllTime
 end

 mutable struct times_save
    time
    network_size
    network_density
 end

mutable struct init
   u0
end


function stim(t,i,stimNodes,Tstim,nWindow,stimOpt,stimWindow,stimStr)
   if i ∈ stimNodes && (Tstim[1] <t < Tstim[2]) && (stimOpt == "on" || stimOpt == "ON") && nWindow == stimWindow
       return stimStr
   else 
       return 0.
   end
end
 