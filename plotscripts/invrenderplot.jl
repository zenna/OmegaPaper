using InvRayTrace: img, img_obs
using JLD2
using Plots
using LaTeXStrings
using Omega
using Omega.Space
using FileIO
# 1. Capture the log likelihood
# 2. Capture The distance to the truth
# 3. Get a wireframe mesh image

const intersectdatapath = "/home/zenna/repos/OmegaModels.jl/models/InvRayTrace.jl/lgMy6nVd/omega957.jld2"
const intersectdata = load(intersectdatapath)["data"]

const nointersectdatapath = "/home/zenna/repos/OmegaModels.jl/models/InvRayTrace.jl/lgMy6nVd/omega957.jld2"
const nointersectdata = load(intersectdatapath)["data"]

fakedata =  [intersectdata for i = 1:1000]
function plotloss!(plt, y; label)
  plot!(plt,
        y,
        ylabel = L"\log f",
        xlabel = L"\textrm{iteration}",
        label = label)
end

pred = logerr(img ==ₛ img_obs)
losses = pred.(fakedata)
plt = Plots.plot()
plotloss!(plt, losses; label = "no intersect")
plotloss!(plt, rand(length(losses)); label = "intersect")


using LaTeXStrings
function ℓvsiter(lines)
  xs = [k.x for k in lines]
  ys = [k.y for k in lines]
  labels = [k.label for k in lines]
  plot(xs, ys,
    ylabel = L"\ell",
    xlabel = L"iteration",
    label = labels,
  )
end

"Plot RMSE vs iteration"
function rmsvsiter(lines)
  xs = [k.x for k in lines]
  ys = [k.y for k in lines]
  labels = [k.label for k in lines]
  plot(xs, ys,
    ylabel = L"\ell",
    xlabel = L"iteration",
    label = labels,
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
rmsey = rand(length(y))
lrmse = (x = x, y = rmsey, label = "RMSE")

rmsenointersect = rand(length(y))
lrmsenointersect = (x = x, y = rmsenointersect, label = "RMSE - nointerect")

p = ℓvstime([l1, l2, l3])
nointersect = rand()