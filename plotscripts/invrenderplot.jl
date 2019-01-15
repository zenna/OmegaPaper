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