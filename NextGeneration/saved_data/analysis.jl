using JLD,Statistics
HOMEDIR = homedir()
workdir = "$HOMEDIR/COMP_paper/NextGeneration/saved_data"
files  = readdir("$workdir")
FC_MATS = files[2:end]
FC_MATS_NOSTIM = FC_MATS[1:25]
FC_MATS_STIM = FC_MATS[26:50]

function get_name(MAT)
    d = findfirst(isequal('_'),MAT)
    return MAT[1:d-1]
end

function get_name_stim(MAT)
    d = findfirst(isequal('_'),MAT)
    return MAT[1:d+4]
end
FCMAT_nostim = zeros(140,140,68,25)
for i = 1:25
    FCMAT_nostim[:,:,:,i] = load("$workdir/$(FC_MATS_NOSTIM[i])",get_name(FC_MATS_NOSTIM[i]))
end

FCMAT_stim = zeros(140,140,68,25)
for i = 1:25
    FCMAT_stim[:,:,:,i] = load("$workdir/$(FC_MATS_STIM[i])",get_name_stim(FC_MATS_STIM[i]))
end

meanFCMAT_nostim = mean(FCMAT_nostim[:,:,10:3:end,:].^2,dims=4)
meanFCMAT_stim = mean(FCMAT_stim[:,:,10:3:end,:].^2,dims=4)


include("/home/pmxjr3/Cyril_Results/Level_3/conver_to_jld.jl")


R2_save[:]
mins = ["00","05","10","15","20","25","30","35","40","45","50","55","60","65","70","75","80","85","90","95","100"]
workdir = "$HOMEDIR/COMP_paper/NextGeneration/saved_data"
for i = 1:size(meanFCMAT_stim,3)

    open("$workdir/text_file_data/modelR2_min_$(mins[i]).txt", "w") do io
        writedlm(io, meanFCMAT_stim[:,:,i], ',')
    end
end

    
