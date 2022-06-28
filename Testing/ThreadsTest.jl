using LinearAlgebra,BenchmarkTools,Random,CUDA,LoopVectorization


function mm!(out,A,B,N)
    @inbounds Threads.@threads for i = 1:N
        for j = 1:N
            out[j,i] += A[j,i].*B[j,i]
        end
    end
end

function get_out!(outv,outm,A,B,ones,N)
    mm!(outm,A,B,N)
    mul!(outv,outm,ones)
end


function get_out2!(outv,outm,A,B,N)
    mul!(outm,A,B)
    outv .= diag(outm)
end


N = 200
du = zeros(8*N)
u = rand(8*N)
d = rand(N)
outm = zeros(N,N)
outv = zeros(N)
outv1 = zeros(N)
outv2 = zeros(N)
ONES = ones(N)
A = rand(N,N)
B = rand(N,N)

@btime get_out!(outv,outm,A,B,ONES,N);

@btime get_out2!(outv1,outm,A,B,N);










