using LinearAlgebra,BenchmarkTools,Random

N =1000
A = rand(N,N) 
A[1:500,1:500] .= 0
shuffle!(A)
B = rand(N,N)
out1 = zeros(N,N)
out2 = zeros(N,N)
out3 = zeros(N,N)

non_zero_idx = findall(A .> 0)

function mmm1!(out,A,B,non_zero_idx)
    @inbounds @simd for i in non_zero_idx
            out[i] = A[i]*B[i]
            end
end

function mmmT1!(out,A,B,N)
    @inbounds Threads.@threads for i = 1:N
        for j = 1:N
            if A[j,i] > 0
                out[j,i] = A[j,i]*B[j,i]
            end
        end
    end
end

function mmmS1!(out,A,B,N)
    @inbounds Threads.@threads for i = 1:N
        @simd for j = 1:N
            if A[j,i] > 0
                out[j,i] = A[j,i]*B[j,i]
            end
        end
    end
end


r1 = rand(1:N)
r2 = rand(1:N)





@btime mmm1!(out1,A,B,N)
@btime mmmT1!(out2,A,B,N)
@btime mmmS1!(out3,A,B,N)


println(out1[r1,r2])
println(out2[r1,r2])
println(out3[r1,r2])