include("common.jl")

using InvRayTrace: img, img_obs, nointersect, scene
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



# TODO
# 1. Get data
# opt 1. Do what I'm doing now (save every n)
# opt 2. Save a big array at the end
# opt 3. 
# 2. Render wireframe photto
# 3. Sort out formatting details

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


const noi = Omega.lift(nointersect)(scene)
const intersectdatapath = "/home/zenna/sketch4/repos/XH3lgZKo/omegas.jld2"
const intersectdata = load(intersectdatapath)["data"].vals
lastscene = scene(intersectdata[end])
# Predicates
const obs = logerr(img ==ₛ img_obs)
const noi = Omega.lift(nointersect)(scene)

# Data
noi_x = noi.(intersectdata)
# obs_x = obs.(intersectdata)
obs_x = load("obs_x.jld2")["obs_x"]

function parsedata(noi_y, obs_y)
  n = length(noi_y)
  [(y = noi_y, x = 1:n, label = L"\textrm{nointersect}"),
   (y = obs_y, x = 1:n, label = L"img ==_s obs")]
end

## Conversions
## ==========
iters = Int.(range(1, length = 5, stop = length(obs_y)))
scenes = [scene(intersectdata[i]) for i in iters]
imgs = [img(intersectdata[i]).img for i in iters]
imgs = shapeup.(imgs)
intersectplots = [saveandplot(scene) for scene in scenes]

function saveandplot(scene)
  voxels = vizintersectvoxels(intersectvoxels(scene.geoms[1:end-2]))
  save("temp.png", voxels)
  voxelimg = load("temp.png")
  Plots.plot(voxelimg, widen = false, margin = 0mm, aspectratio = 1,
                                      framestyle = :none)
end

"Gr id of images"
function images(scenes)
  img_plots = [Plots.plot(img, ticks = false, margin = 0mm, widen = false) for img in imgs]
  Plots.plot(img_plots..., intersectplots..., layout = (2, length(imgs)),
                       widen = false,
                       margin = 0mm,
                       aspectratio = 1,
                       size = (colwidth*up,colwidth*up*2/3),
                      #  framestyle = :none,
                       )
end

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

# Fake data
x = 1:100
imgisobsy = rand(length(x))
imgisobsx = x
l1 = (y = imgisobsy, x = imgisobsx, label = L"obs")

x2 = 1:2:100
nointersecty = rand(length(x2))
nointersectx = x2
l2 = (y = nointersecty, x = nointersectx, label = L"nointersect \land obs")

x3 = 1:2:100
nointersecty = rand(length(x2))
nointersectx = x2
l3 = (y = nointersecty, x = nointersectx, label = "obs")

## Fake RMSE data
rmsey = rand(length(x))
lrmse = (x = x, y = rmsey, label = "RMSE")

rmsenointersect = rand(length(x))
lrmsenointersect = (x = x, y = rmsenointersect, label = "RMSE - nointerect")

"Turn image from array into colours and rotate"
shapeup(img) = RayTrace.rgbimg(permutedims(min.(1.0, img), (2,1,3)) .* )


"Grid of images"
function images()
  img = shapeup(InvRayTrace.img_obs.img)
  plots = [Plots.plot(img, ticks = false, margin = 0mm, widen = false) for i = 1:6]
  Plots.plot(plots..., layout = (2, 3),
                       widen = false,
                       margin = 0mm,
                       aspectratio = 1,
                       size = (colwidth*up,colwidth*up*2/3),
                      #  framestyle = :none,
                       )
end

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