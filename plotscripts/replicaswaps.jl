using Omega
using Omega.Inference: PreSwap, PostSwap
using OmegaTestModels
using Parameters
using Lens
using Base.Iterators
using Plots

# Create a callback to capture which chain is swapping with which chain
function swapscb()
  lastωs = []
  swapmats = Matrix{Float64}[]
  function precb(data)
    lastωs = copy(data.ωs)
  end

  function postcb(data)
    # For each omega in post, we want to know where it came from
    n = length(data.ωs)
    swapmat = zeros(n, n)
    for (i, ω) in enumerate(lastωs)
      @show j = findfirst(x-> ω == x, data.ωs)
      swapmat[i, j] += 1.0
    end
    push!(swapmats, swapmat)
  end
  (precb = precb, postcb = postcb, swapmats = swapmats)
end

function model_()
  x = normal(0, 1)
  cond = x >ₛ 4
  (vars = (x = x,), cond = cond)
end

# model = OmegaTestModels.allmodels[1]
model = model_()
@unpack precb, postcb, swapmats = swapscb()
samples = @leval (PreSwap => precb, PostSwap => postcb) rand((model.vars...,), model.cond, 1000; alg = Replica)

# Do analysis on data
reduce(+, swapmats)

normalize(x) = x ./ sum(x)

function plotswapmat(swapmat)
  plt = Plots.heatmap(normalize(swapmat),
                aspect_ratio = 1,
                label = false,
                colorbar = false,
                color = :amp,
                tickfontsize = 16)
end

tots = reduce(+, swapmats)
nplots = 4
n = length(swapmats) 
swapmatsums = [reduce(+, mats) for mats in Iterators.partition(swapmats, div(n, nplots))]
plots = [plotswapmat(swapmat) for swapmat in swapmatsums]
plt = plot(plots..., layout = (1, nplots))