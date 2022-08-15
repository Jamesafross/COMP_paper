using JLD,Statistics
HOMEDIR = homedir()
workdir = "$HOMEDIR/COMP_paper/NextGeneration/saved_data"
files  = readdir("$workdir")
FC_MATS = files[2:end]
FC_MATS_NOSTIM = FC_MATS[1:13]
FC_MATS_STIM = FC_MATS[14:26]

function get_name(MAT)
    d = findfirst(isequal('_'),MAT)
    return MAT[1:d-1]
end

function get_name_stim(MAT)
    d = findfirst(isequal('_'),MAT)
    return MAT[1:d+4]
end
FCMAT_nostim = zeros(140,140,68)
for i = 1:13
    FCMAT_nostim[:,:,:] += load("$workdir/$(FC_MATS_NOSTIM[i])",get_name(FC_MATS_NOSTIM[i]))/13
end

FCMAT_stim = zeros(140,140,68)
for i = 1:13
    FCMAT_stim[:,:,:] += load("$workdir/$(FC_MATS_STIM[i])",get_name_stim(FC_MATS_STIM[i]))/13
end

diff = abs.(mean(FCMAT_nostim,dims=3)[:,:].^2 .- FCMAT_stim.^2)


meanDiff = zeros(140,140)
for i = 1:140;
    for j = 1:140;
        meanDiff[i,j] = mean(diff[i,j,40:end])
    end
end
