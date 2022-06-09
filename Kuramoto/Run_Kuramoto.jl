include("./setup.jl")
const KP = KuramotoParams(ω = 2.,κ=0.1,σ=0.01)
u0 = 0.18randn(N)
h(p, t; idxs=nothing) = typeof(idxs) <: Number ? 1.0 : u0
tspan = (0.0,1000.0)
p = []
prob = SDDEProblem(Kuramoto,dW,u0, h, tspan, p)
sol = solve(prob,EM(),dt=0.01,maxiters = 1e20)

sol = cos.(sol[:,end-500:end])




R = zeros(N,N)
for i = 1:N
    for j = i:N
        R[i,j] = cor(sol[i,:],sol[j,:])
        R[j,i] = R[i,j]
    end
end


