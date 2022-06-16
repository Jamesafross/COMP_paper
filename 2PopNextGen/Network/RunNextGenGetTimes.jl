mutable struct times_save
    time
    network_size
    network_density
 end

size_SC_vec = [20,30,40,50,60,70,80,90,100,110,120,130,40]
densitySC_vec = [0.3]

times_save_array = Array{times_save}(undef,size(size_SC_vec,1),size(densitySC_vec,1))

counter_i = 1


for i in size_SC_vec
    counter_j = 1
    for j in densitySC_vec
        
        global numThreads = 12

        global nWindows = 5
        global tWindows = 100
        global type_SC = "generated"
        global size_SC = i
        global densitySC=j
        global delay_digits=3
        global plasticityOpt="on"
        global mode="rest"
        global n_Runs=1
        global eta_0E = -14.19
        global kappa = 0.505
        global delays = "on"
        include("/home/james/COMP_paper/2PopNextGen/Network/RunNextGen.jl")

        times_save_array[counter_i,counter_j] = times_save(time_per_second,size_SC,densitySC)
        counter_j += 1

    end
    counter_i += 1
end

times_plot = zeros(size(size_SC_vec,1))

for i = 1:size(size_SC_vec,1)
    times_plot[i] = times_save_array[i,1].time
end



