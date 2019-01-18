include("common.jl")

using InvRayTrace: img, img_obs
import InvRayTrace
import RayTrace
using JLD2
using Omega
using Omega.Space
using FileIO
using Images

# TODO
# 1. Get data
# opt 1. Do what I'm doing now (save every n)
# opt 2. Save a big array at the end
# opt 3. 
# 2. Render wireframe photto
# 3. Sort out formatting details

# 1. Capture the log likelihood
# 2. Capture The distance to the truth
# 3. Get a wireframe mesh image

# const intersectdatapath = "/home/zenna/repos/OmegaModels.jl/models/InvRayTrace.jl/lgMy6nVd/omega957.jld2"
# const intersectdata = load(intersectdatapath)["data"]

# const nointersectdatapath = "/home/zenna/repos/OmegaModels.jl/models/InvRayTrace.jl/lgMy6nVd/omega957.jld2"
# const nointersectdata = load(intersectdatapath)["data"]

# fakedata =  [intersectdata for i = 1:1000]
# function plotloss!(plt, y; label)
#   plot!(plt,
#         y,
#         ylabel = L"\log f",
#         xlabel = L"\textrm{iteration}",
#         label = label)
# end

# pred = logerr(img ==ₛ img_obs)
# losses = pred.(fakedata)
# plt = Plots.plot()
# plotloss!(plt, losses; label = "no intersect")
# plotloss!(plt, rand(length(losses)); label = "intersect")


function ℓvsiter(lines)
  xs = [k.x for k in lines]
  ys = [k.y for k in lines]
  labels = [k.label for k in lines]
  Plots.plot(xs, ys,
    ylabel = L"\ell",
    xlabel = L"iteration",
    # label = labels,
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
shapeup(img) = RayTrace.rgbimg(permutedims(min.(1.0, img), (2,1,3)))

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
                     size = (colwidth*up, colwidth*up*4/3),
                     tickfontsize = 32,
                    #  legendfontsize = 32m,
                     margin = 0mm,
                     widen = false,
                     legend = :topright,
                     legendfont = fntsm)
  save && Plots.savefig(plt, joinpath(PAPERHOME, "invg.pdf"))
  plt
end