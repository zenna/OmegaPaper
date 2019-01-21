include("common.jl")
## Surface Plots
using Distributions
using Omega
using Makie
using GeometryTypes: HyperRectangle
using FileIO
using QuadGK


x = uniform(-1, 1)
y = uniform(-2, 2)
px = x ==ₛ 0
==ᵧ, γ = Omega.softeqgamma(1.0)
py = y ==ᵧ 0
z = px | py
function getdata(γ_)
  γ[] = γ_

  samples = withkernel(kseα(10)) do
    rand((px, py, x, y), z, 100000; alg = NUTS)
  end
  pxs_, pys_, xs_, ys_ = ntranspose(samples)
  xs = val.(x_)
  ys = val.(y_)
  (pxs = pxs_, pys_ = pys_, xs = xs_, ys = ys_, γ = γ_)
  # histogram2d(xs, ys, nbins = 50)
end

d1 = getdata(1.0)
d2 = getdata(2.546392e-01)

using LaTeXStrings
# Plot Data
p1a = histogram2d(val.(d1.xs), val.(d1.ys), color = :amp, nbin = 50, label = false,
                  legend = false, title = L"x = y ∧ y = 0, \gamma = 1", xticks = [-1, 0, 1], yticks = [-2, 0, 2], frame = :box, top_margin = 3mm)
p1b = histogram(val.(err.(d1.pxs)), legend = false, xticks = [0, 0.5, 1], normalize = true, widen = false, title = "f_x, \gamma = 1")
p1c = histogram(val.(err.(d1.pys_)), legend = false, xticks = [0, 0.5, 1], normalize = true, widen = false, title = "f_y, \gamma = 1")

p2a = histogram2d(val.(d2.xs), val.(d2.ys), color = :amp, nbin = 50, label = false,
                  legend = false, title = L"x = y ∧ y = 0, \gamma = 0.25", xticks = [-1, 0, 1], yticks = [-2, 0, 2], frame = :box, top_margin = 3mm)
p2b = histogram(val.(err.(d2.pxs)), legend = false, xticks = [0, 0.5, 1], normalize = true, widen = false, title = "f_x, \gamma = 0.25")
p2c = histogram(val.(err.(d2.pys_)), legend = false, xticks = [0, 0.5, 1], normalize = true, widen = false, title = "f_y, \gamma = 0.25")

plt = plot(p1a, p1b, p1c, p2a, p2b, p2c,
           layout = (2,3),
          #  widen = false,
           label = false,
           size = (3, 2) .* colwidth .* up,
           tickfontsize = 40,
          #  legendfontsize = 32m,Improving ABC for quantile distributions
           margin = 30mm,
           titlefontsize = 40,
           legendfontsize = 40)

savefig(plt, joinpath(FIGURESPATH, "scaling.pdf"))

function loss(v)
  @show v
  γ[] = v[1]
  samples = withkernel(kseα(10)) do
    rand((px, py, x, y), z, 10000; alg = NUTS)
  end
  px_, py_, x_, y_ = ntranspose(samples)
  @show a = mean(val.(err.(px_)))
  @show b = mean(val.(err.(py_)))
  @show abs(a - b)
end

# Solve analytically
fx_(x) = log(0.5) + kse(Omega.d(x, 0), 1)
Zx = quadgk(fx_, -1, 1)[1]
fx(x) = fx_(x) - Zx

fy_(y) = log(1/4) + kse(Omega.d(y, 0), α)
Zy = quadgk(fy_, -2, 2)[1]
fy(y) = fy_(y) - Zy
Zx, Zy

function energy(f, lb, ub)
  g_f(k) = x -> float(f(x) > k)
  e(y) = quadgk(g_f(y), lb, ub)[1]
end

function loss(alpha)
  α = alpha[1]
  fx_(x) = log(0.5) + kse(Omega.d(x, 0), 1)
  Zx = quadgk(fx_, -1, 1)[1]
  fx(x) = fx_(x) - Zx
  exp_fx(x) = x*exp(fx(x))
  a = quadgk(exp_fx, -1, 1)[1]

  fx_(x) = 0.5 * exp(- 2.718281828459045 * Omega.d(x, 0))
  Zx = quadgk(fx_, -1, 1)[1]
  fx(x) = fx_(x) / Zx
  e = energy(fx, -1, 1)
  Ze = quadgk(e, 0, 1)[1]
  exp_fx(x) = x*e(x)
  @show a = quadgk(exp_fx, 0, 1)[1]

  
  fy_(y) = log(1/4) + kse(Omega.d(y, 0), α)
  Zy = quadgk(fy_, -2, 2)[1]
  fy(y) = fy_(y) - Zy
  exp_fy(y) = y*fy(y)
  b = quadgk(exp_fy, -2, 2)[1]

  @show a, b
  @show abs(a - b)
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
            )
  p2 = lines(xlb:0.001:xub, fx)
  p3 = lines(ylb:0.001:yub, fy)
  hbox(p2,
       vbox(p1, p3), sizez = [2/3, 1/3])
  # scene = viz(apprxpost(p, u, x = 0:0.01:1,
  #                             y = 0:0.01:2,),)
  # setsize!(scene, 1000, 1000)
  # scene
end
