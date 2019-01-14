using Plots
using Omega
using Parameters
using Callbacks
using StatPlots: marginalhist
using Plots.PlotMeasures
include(joinpath(dirname(pathof(Omega)), "viz.jl"))

function prob1()
  x = uniform(-1.0, 1.0)  
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = x ==ₛ y, xlims = (-1, 1), ylims = (-1, 1))
end

function prob2()
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = x >ₛ y, xlims = (-1, 1), ylims = (-1, 1))
end

function prob3()
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = abs(x) >ₛ abs(y), xlims = (-1, 1), ylims = (-1, 1))
end

function prob4()
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = x^2 ==ₛ y^2, xlims = (-1, 1), ylims = (-1, 1))
end

function prob5(k = 3, thresh = 0.9999)
  x = uniform(0.0, 1.0)
  y = uniform(0.0, 1.0)
  c = (sin(2π * x * k) * cos(2π * y * k)) >ₛ thresh
  (x = x, y = y, c = c, xlims = (0, 1), ylims = (0, 1))
end

function prob6(k = 3, thresh = 0.8)
  x = uniform(0, 1.0)
  y = uniform(0, 1.0)
  c = (sin(2π * x * k) * cos(2π * y * k)) >ₛ thresh
  (x = x, y = y, c = c, xlims = (0, 1), ylims = (0, 1))
end

function prob7(k = 3, thresh = 0.8)
  x = uniform(-1.0, 1.0)
  y = uniform(-100.0, 100.0)
  c = (x ==ₛ 0.0) & (y ==ₛ 0.0)
  (x = x, y = y, c = c, xlims = (-1, 1), ylims = (-100, 100))
end

function allsamples(prob, n; algkwargs...)
  # ωsamples = rand(defΩ(), logerr(prob.c), n, alg, kwargs...)
  # xy = randtuple((prob.x, prob.yy))
  # samples = map(ω -> applynotrackerr(x, ω), ωsamples)

  # ωsamples = rand((prob.x, prob.y), prob.c, n; alg = alg, kwargs...)
  # (ωsamples = ωsamples, samples = samples)
  cb, losses = Callbacks.capturevals(:p, Float64)
  samples = rand((prob.x, prob.y), prob.c, n; cb = cb, algkwargs...)
  (samples = samples, ωsamples = nothing, losses = losses)
end

function scatterxy(samples;
                   label = nothing, legend = nothing, xlims = (-1, 1),
                   ylims = (-1, 1), kwargs...)
  xs, ys = ntranspose(samples)
  # scatter(xs, ys, label = label, legend = legend, xlims = xlims, ylims = ylims)
  # marginalhist(xs, ys, label = label, legend = legend, xlims = xlims, ylims = ylims, nbins = 50)
  histogram2d(xs, ys, nbins=50, bottom_margin=0mm,  widen=false, framestyle=:box,
              margin=0mm, legend=false, xlims = xlims, ylims = ylims,
              color=:amp)
end

function convergence!(data, plt)
  @show length(data)
  plot!(plt, data, legend = nothing)
end

function vizall(probs, algs, n)
  plots = []
  for prob in probs
    probplots = []
    @unpack x, y, c, xlims, ylims = prob
    push!(probplots, ωcontour(err(c); label = nothing,
                                  legend = nothing,
                                  colorbar = nothing,
                                  color = :amp))
    # Convergence Plot                                  
    # convergenceplot = plot()
    # push!(probplots, convergenceplot)
    for alg in algs
      try
        @unpack samples, ωsamples, losses = allsamples(prob, n; alg...)
        push!(probplots, scatterxy(samples, xlims = xlims, ylims = ylims))
        # convergence!(losses, convergenceplot)
      catch e
        println("Failed")
        display(e)
        # rethrow(e)
        push!(probplots, plot())
      end
    end
  push!(plots, probplots)  
  end
  plots
end

probs = [prob1(), prob2(), prob3(), prob4(), prob5(), prob6()]
algs = [(alg = SSMH,),
        (alg = NUTS,),
        (alg = Replica, nreplicas = 4, inneralg = SSMH),
        # (alg = Replica, nreplicas = 4, inneralg = NUTS),
        ]

flatten(xs) = vcat([x for x in xs]...)

function makeplots(plots)
  flatplots = flatten(plots)
  @show nrows, ncols = length(plots), length(plots[1])
  multiplier = 200
  plt = plot(flatplots..., layout = (nrows, ncols),
                           markersize=0.01,
                           tickfontsize = 4,
                           aspectratio = 1,
                           margin = 0mm,
                           size = (ncols, nrows) .* multiplier)
end

plots = vizall(probs, algs, 10000)
makeplots(plots)

# n = 8
# temps = Omega.Inference.logtemps(n)
# temps = [1e-9, 10000]
# withkernel(kseα(temps[end])) do
#   @unpack x, y, c = prob6()
#   # p1 = ωcontour(err(c); label = nothing, legend = nothing);
#   p2 = ωcontour(logerr(c); label = nothing, legend = nothing)
#   # samples = rand((x, y), c, 100000; alg = Replica, nreplicas = 8, temps = temps)
#   # p3 = scatterxy(samples, xlims = (0, 1), ylims = (0, 1))
#   # plot(p1, p3, markersize = 0.01, aspectratio = 1)
# end
