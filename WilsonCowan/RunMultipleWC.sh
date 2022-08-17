#!/bin/bash

cd /home/james/COMP_paper/WilsonCowan/

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
do
echo $i
julia -t6 RunWilsonCowan.jl
mv ./saved_data/modelFC_stim.jld ./saved_data/modelFC_stim_run_$i.jld
done

