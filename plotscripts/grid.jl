include("common.jl")
import Plots
using Omega
using Parameters
using Callbacks
# using StatPlots: marginalhist
using Plots.PlotMeasures: mm
using Flux
using LaTeXStrings
include(joinpath(dirname(pathof(Omega)), "viz.jl"))

# Problems


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
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  c = (sin(2π * x * k) * cos(2π * y * k)) >ₛ thresh
  (x = x, y = y, c = c, xlims = (-1, 1), ylims = (-1, 1))
end

function prob6(k = 3, thresh = 0.8)
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  c = (sin(2π * x * k) * cos(2π * y * k)) >ₛ thresh
  (x = x, y = y, c = c, xlims = (-1, 1), ylims = (-1, 1))
end

function prob7(k = 3, thresh = 0.8)
  x = uniform(-1.0, 1.0)
  y = uniform(-100.0, 100.0)
  c = (x ==ₛ 0.0) & (y ==ₛ 0.0)
  (x = x, y = y, c = c, xlims = (-1, 1), ylims = (-100, 100))
end

# Get Data
function allsamples(prob, n; algkwargs...)
  cb, losses = Callbacks.capturevals(:p, Float64)
  samples = rand((prob.x, prob.y), prob.c, n; cb = cb, algkwargs...)
  (samples = samples, losses = losses)
end

function getdata(probs, algs, n)
  plots = []
  data = []
  for prob in probs
    for alg in algs
      try
        println("Trying $prob on $alg")
        @unpack samples, losses = allsamples(prob, n; alg...)
        res = (prob = prob, alg = alg, samples = samples, losses = losses, fail = false)
        push!(data, res)
      catch e
        println("Failed")
        res = (prob = prob, alg = alg, fail = true)
        push!(data, res)
        # display(e)
        rethrow(e)
      end
    end
  end
  data
end

# Plot data
function ωcontourhack(xrv::RandVar;
                      ΩT = defΩ(),
                      xdim = 1,
                      ydim = 2,
                      xrng = -1:0.005:1,
                      yrng = -1:0.005:1,
                      plt = plot(),
                      fill = true,
                      kwargs...)
  ω = ΩT()
  xrv(ω)
  function f(x, y)
    ω = Space.update(ω, xdim, x / 2.0 + 0.5)
    ω = Space.update(ω, ydim, y / 2.0 + 0.5)
    xrv(ω)
  end
  contour!(plt, xrng, yrng, f; fill = fill, kwargs...)
end

function scatterxy(samples;
                   label = nothing, legend = nothing, xlims = (-1, 1),
                   ylims = (-1, 1), kwargs...)
  xs, ys = ntranspose(samples)
  # scatter(xs, ys, label = label, legend = legend, xlims = xlims, ylims = ylims)
  # marginalhist(xs, ys, label = label, legend = legend, xlims = xlims, ylims = ylims, nbins = 50)
  @show typeof(Flux.data(xs))
  histogram2d(Flux.data.(xs), Flux.data.(ys), nbins=50, bottom_margin=0mm,  widen=false, framestyle=:box,
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
    # @unpack x, y, c, xlims, ylims = prob
    push!(probplots, ωcontourhack(err(c); label = nothing,
                                  legend = nothing,
                                  colorbar = nothing,
                                  color = :amp))
    # Convergence Plot                                  
    # convergenceplot = plot()
    # push!(probplots, convergenceplot)
    for alg in algs
      try
        @unpack samples, ωsamples, losses = allsamples(prob, n; alg...)
        push!(probplots, scatterxy(samples,
                                  #  xlims = xlims,
                                  #  ylims = ylims
                                   )
                                   )
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

function vizdata(rows)
  plots = []
  for row in rows
    c = row[1].prob.c
    push!(plots, ωcontourhack(err(c); label = nothing,
                              legend = nothing,
                              colorbar = nothing,
                              color = :amp))
    for datum in row
      push!(plots, scatterxy(val.(datum.samples)))
    end
  end
  plots
end



# function vizdata(data)
#   plots = []
#   for datum in data
#     @unpack prob, alg, samples = datum
#     push!(probplots, ωcontourhack(err(prob.c); label = nothing,
#                                                 legend = nothing,
#                                                 colorbar = nothing,
#                                                 color = :amp))
#   for prob in probs
#     push!(probplots, ωcontourhack(err(c); label = nothing,
#                                   legend = nothing,
#                                   colorbar = nothing,
#                                   color = :amp))
#     for alg in algs
#       push!(probplots, scatterxy(samples,
#                                 #  xlims = xlims,
#                                 #  ylims = ylims
#       )
#     end
#   end
#   plots
# end


# Do it all!
probs = [prob1(), prob2(), prob3(), prob4(), prob5(), prob6()]
algs = [
        (alg = SSMH,),
        (alg = NUTS,),
        (alg = Replica, nreplicas = 4, inneralg = SSMH),
        (alg = Replica, nreplicas = 4, inneralg = NUTS, ΩT = defΩ(NUTS)),
        # (alg = HMCFAST, stepsize = 0.001, nsteps = 100),
        # (alg = Replica, nreplicas = 4, inneralg = HMCFAST,
        #  ΩT = SimpleΩ{Vector{Int}, Flux.TrackedArray}, algargs = (stepsize = 0.001, nsteps = 100))
        ]

flatten(xs) = vcat([x for x in xs]...)

data = getdata(probs, algs, 10000)
plots = vizdata(data)
@save "data2.jld2" data

# plots = vizall(probs, algs, 10000)
# st = L"x + y < 0"
# ltxstrings = [L"x = y", L"x > y", L"|x| > |y|", L"x^2 = y^2", L"\sin(kx)\cos(kx) < \epsilon_1", L"\sin(kx)\cos(kx) < \epsilon_2"] 
# algstrings = ["", "SSMH", "NUTS", "RE-SSMH", "RE-NUTS"]

# function makeplots(plots)
#   # foreach((plt, st) -> ylabel!(plt[1], st), plots, ltxstrings)
#   foreach((plt, st) -> title!(plt, st), plots[1], algstrings)
#   flatplots = flatten(plots)
#   @show nrows, ncols = length(plots), length(plots[1])
#   multiplier = 400
#   plt = plot(flatplots..., layout = (nrows, ncols),
#                            markersize=0.01,
#                            tickfontsize = 24,
#                            aspectratio = 1,
#                            xticks = [-1, 1],
#                            yticks = [-1, 1],
#                            margin = 0mm,
#                            top_margin = 10mm,
#                            size = (ncols, nrows) .* multiplier,
#                           #  fontfamily = font(50),
#                            guidefontsize = 30,
#                            legendfontsize = 24,
#                            titlefontsize = 30
#                           )
# end

# plt = makeplots(plots)
# savefig(plt, "grid4.png")
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
