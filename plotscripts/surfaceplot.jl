## Surface Plots
using Distributions
using Omega
using Makie
using GeometryTypes: HyperRectangle
using FileIO
# using Plots

len(rng) = maximum(rng) - minimum(rng)

function apprxpost(p, u, f;
                   x = 0:0.001:1,
                   y = 0:0.001:1,
                   αs = [1, 100, 100000],
                   limits = HyperRectangle(minimum(x), minimum(y), 0.0,
                                           len(x), len(y), 1.0))
  plots = []
  for α in αs
      innerplots = withkernel(kseα(α)) do
      p1 = surface(x, y, p,
                  legend = false,
                  # limits = limits
                  )
      p2 = surface(x, y, u,
                  legend = false,
                  limits = limits
                  )
      p3 = surface(x, y, f,
                  legend = false,
                  # limits = limits
                  )
      # plot(p1, p2, p3, layout = (1, 3))
      [p1, p2, p3]
    end
    push!(plots, innerplots)
  end
  plots
end

setsize!(scene, width, height) = push!(scene.px_area, HyperRectangle(0, 0, width, height))


## Normal Normal
function nn()
  viz(plots) = hbox([vbox(plts...) for plts in plots]...)

  p(μ, x) = pdf(Beta(3, 4), μ) * pdf(Normal(μ), x)
  u(μ, x) = err(x ==ₛ 0.5)
  f(μ, x) = p(μ, x) * u(μ, x)
  viz(apprxpost(p, u, f))
end

## Spiky
function spiky()
  p(μ, x) = pdf(Normal(0, 0.5), μ) * pdf(Normal(0, 0.8), x)
  u(x, y, thresh = 0.99, k = 2) =
    err((sin(2π * x * k) * sin(2π * y * k)) >ₛ thresh)
  f(μ, x) = p(μ, x) * u(μ, x)
  scene = viz(apprxpost(p, u, f;
                        x = -1:0.001:1, y = -1:0.001:1,
                        αs = [0.0001, 1, 100000]))

  setsize!(scene, 1000, 1000)
  FileIO.save("approxpost.png", scene)
end

## Spiky
function wow()
  p(μ, x) = pdf(Normal(0, 0.5), μ) * pdf(Normal(0, 0.8), x)
  u(x, y, thresh = 0.99, k = 2) =
    err((x >ₛ y) | (y ==ₛ 0))
  f(μ, x) = p(μ, x) * u(μ, x)
  scene = viz(apprxpost(p, u, f;
                        x = -1:0.001:1, y = -1:0.001:1,
                        αs = [0.0001, 1, 100000]))

  setsize!(scene, 1000, 1000)
  scene
end

θ = uniform(-10, 10)
x = normal(θ, 1) + normal(θ, 0.1)
rand(θ, x ==ₛ 0, 10000, alg = SSMH)

function wow(σ = 0.1)
  p(x) = pdf(Normal(0, 1), x) + pdf(Normal(0, σ), x)
  u(x) = err((x >ₛ y) | (y ==ₛ 0))
  f(μ, x) = p(μ, x) * u(μ, x)
  scene = viz(apprxpost(p, u, f;
                        x = -1:0.001:1, y = -1:0.001:1,
                        αs = [0.0001, 1, 100000]))

  setsize!(scene, 1000, 1000)
  scene
end



function dunno()
  ## Param Estimation
  p(μ, x) = pdf(Normal(0, 1), μ) * pdf(Normal(μ, 1), x)
  u(μ, x) = err(x ==ₛ 0)
  f(μ, x) = p(μ, x) * u(μ, x)
  x =  y = -3:0.1:3
end
