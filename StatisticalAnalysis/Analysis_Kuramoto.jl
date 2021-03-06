using JLD
using DelimitedFiles,Statistics,Plots

HOMEDIR=homedir()
workdir = "$HOMEDIR/NetworkModels/StatisticalAnalysis"

SCFCDATADIR="$HOMEDIR/NetworkModels_Data/StructDistMatrices"
include("$SCFCDATADIR/getData.jl")
include("$workdir/functions.jl")

SC_Array,FC_Array,dist = getData_nonaveraged(;SCtype="log")

HOMEDIR = homedir()
INDATADIR = "$HOMEDIR/NetworkModels_Data/Kuramoto/"
OutDATADIR = "$HOMEDIR/NetworkModels_Data/Rcode_Data/2PopNextGen_Data"



function getFCwindows(SIG;type="r")
    FC = zeros(139,139)
    if type == "r"
        for ii = 1:139
            for jj = ii+1:139
                FC[ii,jj] = cor(SIG[ii,:],SIG[jj,:])
                FC[jj,ii] =  FC[ii,jj]
            end
        end
    
    elseif type == "phase"
            # Compute FC
            U_trans=imag(hilbert(SIG'))
            U_trans = U_trans'
            R=zeros(139,139);
            for n=1:139-1
                for m=n+1:139
                    FC[n,m]=abs((1/size(U_trans)[1]*sum(exp.(im*(U_trans[m,:]-U_trans[n,:])))));
                    FC[m,n]=FC[n,m];
                end
            end
    end
    return FC
end


savedir = "Run_1"

buffer = 100


BOLD = load("$INDATADIR/$savedir/BOLD_Kuramoto.jld","BOLD_Kuramoto")[:,buffer:end]

step_i = 5
step_j = 100
counterT = 1
for i = 1:step_i:size(BOLD,2)
    j = i + step_j
    if j < size(BOLD,2)
        counterT +=1
    else
        break
    end
end


counter = 1
TYPE = "r"


global FCstim = zeros(139,139,counterT) 
global FCnostim = zeros(139,139,counterT) 


runs = [1]
for run in runs
   
    global BOLDstim = load("$INDATADIR/$savedir/BOLD_Kuramoto.jld","BOLD_Kuramoto")[:,buffer:end]
    BOLDnostim = load("$INDATADIR/$savedir/BOLD_Kuramoto.jld","BOLD_Kuramoto")[:,buffer:end]

    
    counter = 1
    for i = 1:step_i:size(BOLDstim,2)
        j = i + step_j
        if j < size(BOLDstim,2)
            global FCstim[:,:,counter] += getFCwindows(BOLDstim[:,i:j];type=TYPE)/length(runs)
            global FCnostim[:,:,counter] += getFCwindows(BOLDnostim[:,i:j];type=TYPE)/length(runs)
            counter += 1
            #println(counter)
            
        else
            break
        end
    end

end




anim1 = @animate for i = 1:1:counterT
    t = buffer*1.6 + round((i-1)*1.6*2,digits=2) + step_j*1.6 
    p1 = heatmap(FCstim[:,:,i],c=:jet,title=t)
    plot(p1,title=i)
end

anim2 = @animate for i = 1:1:counterT
    t = buffer*1.6 + round((i-1)*1.6*2,digits=2) + step_j*1.6 
    p1 = heatmap(FCstim[:,:,i],c=:jet,title=t)
    plot(p1,title=i)
end

FCstim_rv = []
FCnostim_rv = []
rv=0
buff = 20
if rv == 1
    for i = buff+1:size(FCstim,3)
        j = i+buff
        jj = i-buff
        
        if j < size(FCstim,3)
            if i == buff+1
                FCstim_rv = mean(FCstim[:,:,jj:j],dims=3)
                FCnostim_rv = mean(FCnostim[:,:,jj:j],dims=3)
            else
                FCstim_rv = cat(FCstim_rv,mean(FCstim[:,:,jj:j],dims=3),dims=3)
                FCnostim_rv = cat(FCnostim_rv,mean(FCnostim[:,:,jj:j],dims=3),dims=3)
            end
        end
    end

    anim2 = @animate for i = 1:1:size(FCstim_rv,3)
        t = buffer*1.6 + round((i-1)*1.6*2,digits=2) + step_j*1.6 
        p1 = heatmap(FCstim_rv[:,:,i].^2,c=:jet,title=t)
        plot(p1)
    end
end

sFC = size(FC_Array,3)

fitFC = zeros(sFC,size(FCstim,3))
fitFCmean = zeros(size(FCstim,3))
fitFC2 = zeros(sFC,size(FCstim,3))
fitFCmean2 = zeros(size(FCstim,3))

for i = 1:size(FCstim,3)
    fitFCmean[i] = fitR(FCnostim[:,:,i],mean(FC_Array[:,:,:],dims=3)[:,:])
    fitFCmean2[i] = fitR(FCnostim[:,:,i].^2,mean(FC_Array[:,:,:].^2,dims=3)[:,:])
    for j = 1:sFC
        fitFC[j,i] = fitR(FCnostim[:,:,i],FC_Array[:,:,j])
        fitFC2[j,i] = fitR(FCnostim[:,:,i].^2,FC_Array[:,:,j].^2)
    end
end







gif(anim1,"anim1.gif",fps=20)




