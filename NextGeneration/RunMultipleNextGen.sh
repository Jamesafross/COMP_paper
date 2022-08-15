#!/bin/bash

cd /home/james/COMP_paper/NextGeneration/

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
do
echo $i
julia -t6 RunNextGen.jl
mv ./saved_data/modelFC.jld ./saved_data/modelFC_run_$i.jld
mv ./saved_data/modelFC_stim.jld ./saved_data/modelFC_stim_run_$i.jld
done

