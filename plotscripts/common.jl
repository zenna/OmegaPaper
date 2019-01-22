import Plots
using Plots.PlotMeasures: mm
using LaTeXStrings
import Flux
import ForwardDiff

colwidth = 82

up = 8 #8x upscaling in resolution
fntsm = Plots.font("sans-serif", 12)
fntlg = Plots.font("sans-serif", 12)
Plots.default(titlefont=fntlg, guidefont=fntlg, tickfont=fntsm, legendfont=fntsm)
Plots.default(size=(colwidth*up,colwidth*up)) #Plot canvas size
Plots.default(dpi=300) #Only for PyPlot - presently broken

PAPERHOME = "/home/zenna/repos/papers/OmegaPaper/"
FIGURESPATH = joinpath(PAPERHOME, "figures")

val(x::ForwardDiff.Dual) = x.value
val(x::Flux.TrackedArray) = Flux.data(x)
val(x::Flux.Tracker.TrackedReal) = Flux.data(x)
val(x) = x
