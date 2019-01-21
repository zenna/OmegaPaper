## Surface Plots
using Distributions
using Omega
using Makie
using GeometryTypes: HyperRectangle
using FileIO
using QuadGK


function energy(f, lb, ub)
  g_f(k) = x -> float(f(x) > k)
  e(y) = quadgk(g_f(y), lb, ub)[1]
end

f(x) = err(x ==ₛ 0.0)
e = energy(f, -0.4, 0.4)
plt1 = plot(e, 0, 1)
plt2 = plot(f, -0.4, 0.4)
plot(plt2, plt1)
## Normal Normal
function scalediff()
  xlb, xub = 0.0, .1
  ylb, yub = 0.0, .3
  p(x, y) = pdf(Uniform(xlb, yub), x) * pdf(Uniform(ylb, yub), y)
  u(x, y) = err((x ==ₛ 0.05) | (y ==ₛ 0.15))
  x = xlb:0.001:xub
  y = ylb:0.01:yub
  f = (μ, x) -> p(μ, x) * u(μ, x)
  fx(x) = quadgk(y -> f(x, y), ylb, yub)[1]
  fy(y) = quadgk(x -> f(x, y), xlb, xub)[1]
  p1 = contour(x, y, f.(x, y'),
            legend = false,
            # limits = limits
            )``
  p2 = lines(xlb:0.001:xub, fx)
  p3 = lines(ylb:0.001:yub, fy)
  hbox(p2,
       vbox(p1, p3), sizez = [2/3, 1/3])
  # scene = viz(apprxpost(p, u, x = 0:0.01:1,
  #                             y = 0:0.01:2,),)
  # setsize!(scene, 1000, 1000)
  # scene
end
