include("common.jl")

using InvRayTrace: img, img_obs, nointersect, scene, orthographic!
import InvRayTrace
include(joinpath(dirname(pathof(InvRayTrace)), "viz.jl")) # Include Viz
import RayTrace
using JLD2
using Omega
using Omega.Space
using FileIO

using Images
using Plots
using LaTeXStrings
pyplot()

# 1. Capture the log likelihood
# - Capture The distance to the truth
# - Get a wireframe mesh image

# TODO: Save the loss value

# TODO:
# Get second dataset in
# RMSE plot
# Which image plots to show
# Run again but
  #  saving the loss value and
  # - Saving the exchange rate
  # And maybe do the chaisn in parallel? maybe unnecessary

# Predicates
const obspred = logerr(img ==ₛ img_obs)
const noipred = logerr(lift(nointersect)(scene))

const ωspath = "/home/zenna/sketch3/repos/XH3lgZKo/omegas.jld2"
const iωs = load(ωspath)["data"].vals

const noiωspath = "/home/zenna/sketch3/repos/data/7vwt0cn1/omegas.jld2"
const noiωs = load(noiωspath)["data"].vals

# Data
noi_obs = noipred.(ωs)
ℓ_obs = load("/home/zenna/sketch3/repos/data/obs_x.jld2")["obs_x"]

# Data
noi_noi = noipred.(noiωs)
ℓ_noi = load("/home/zenna/sketch3/repos/data/ellother.jld2")["ℓ_noi"]

function parsedata(noi_y, obs_y)
  n = length(noi_y)
  [(y = noi_y, x = 1:n, label = L"\textrm{nointersect}"),
   (y = obs_y, x = 1:n, label = L"img ==_s obs")]
end

## Images
## ======
"Turn image from array into colours and rotate"
shapeup(img) = RayTrace.rgbimg(permutedims(min.(1.0, img), (2,1,3)))

function plotvoxels(scene)
  voxels = vizintersectvoxels(intersectvoxels(scene.geoms[1:end-2]))
  # orthographic!(voxels)
  save("temp.png", voxels)
  voxelimg = load("temp.png")
  Plots.plot(voxelimg, widen = false, margin = 0mm, aspectratio = 1,
                                      framestyle = :none)
end

"Rendered imgages for chain"
function renderchain(ωs)
  imgs = [img(ω).img for ω in ωs]
  imgs = shapeup.(imgs)
  plot.(imgs)
end

"Voxel Images for chain"
function voxelchain(ωs)
  scenes = [scene(ω) for ω in ωs]
  bothplots = [plotvoxels(scene) for scene in scenes]
end


function plotchainimgs(imgs, nrows, ncols)
  Plots.plot(imgs..., layout = (nrows, ncols),
                       widen = false,
                       margin = 0mm,
                       aspectratio = 1,
                       size = (colwidth*up,colwidth*up/3),
                       xticks = false,
                       framestyle = :none,
                       )
end

function plot_figinvrtmcmc(ωs; iters = Int.(range(1, length = 5, stop = length(ωs))),
                               save = false,
                               fname)
  ωschain = [ωs[i] for i in iters]
  p1 = renderchain(ωschain)
  p2 = voxelchain(ωschain)
  plt = plotchainimgs(vcat(p1, p2), 2, length(p1))
  save && savefig(plt, joinpath(PAPERHOME, fname))
  plt
end

plot_figinvrtmcmc(noiωs, save = true, fname = "invgb.pdf")

## Convergence
## ===========
lines = vcat(parsedata(obs_x, logerr.(noi_x)))
p1 = ℓvsiter(lines)

rs(x::Vector) = reshape(x, (1, length(x))) 

function ℓvsiter(lines)
  xs = [k.x for k in lines]
  ys = [k.y for k in lines]
  labels = [k.label for k in lines]
  labels = [L"nointersect",L"img \tilde{=} obs"]
  Plots.plot(xs, ys,
    ylabel = L"\ell",
    xlabel = L"iteration",
    label = rs(labels),
  )
end

"Plot RMSE vs iteration"
function rmsvsiter(lines)
  xs = [k.x for k in lines]
  ys = [k.y for k in lines]
  labels = [k.label for k in lines]
  Plots.plot(xs, ys,
    ylabel = L"\ell",
    xlabel = L"iteration",
    # label = labels,
  )
end

## Everything 
## ==========
function plot_invg(; save)
  pimg = images()
  layout = Plots.grid(3, 1, heights=[1/2,1/4,1/4])
  p1 = ℓvsiter([l1, l2, l3])
  p2 = rmsvsiter([lrmse, lrmsenointersect])
  plt = Plots.plot(pimg, p1, p2,
                    layout = layout,
                    #  title = "Big Plot",
                     size = (colwidth*up, coImproving ABC for quantile distributionsdth*up*4/3),
                     tickfontsize = 32,
                    #  legendfontsize = 32m,Improving ABC for quantile distributions
                     margin = 0mm,
                     widen = false,
                     legend = :topright,
                     legendfont = fntsm)
  save && Plots.savefig(plt, joinpath(PAPERHOME, "invg.pdf"))
  plt
end