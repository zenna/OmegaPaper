import Plots
using Plots.PlotMeasures: mm
using LaTeXStrings

colwidth = 82

up = 8 #8x upscaling in resolution
fntsm = Plots.font("sans-serif", 32)
fntlg = Plots.font("sans-serif", 32)
Plots.default(titlefont=fntlg, guidefont=fntlg, tickfont=fntsm, legendfont=fntsm)
Plots.default(size=(colwidth*up,colwidth*up)) #Plot canvas size
Plots.default(dpi=300) #Only for PyPlot - presently broken

PAPERHOME = "/home/zenna/repos/papers/OmegaPaper/"
FIGURESPATH = joinpath(PAPERHOME, "figures")