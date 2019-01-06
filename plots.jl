using Omega
using Plots
using LaTeXStrings

columnwidth = 7

## Negation 

plots = withkernel(kseα(10)) do
  pred = x -> x > 0
  p1 = Plots.plot([x -> err(x >ₛ 0), pred], -1, 1,
                  title = L"(a) \; x \tilde{>} 0",
                  xlabel = "x",
                  linestyle = [:solid :dash],
                  legend = false)
  p2 = Plots.plot([x -> 1 - err(x >ₛ 0), !pred], -1, 1,
                  title = L"(b) \;1 - (x \tilde{>} 0)",
                  xlabel = "x",
                  linestyle = [:solid :dash],
                  legend = false)
  p3 = Plots.plot([x-> err(!(x >ₛ 0)), !pred], -1, 1,
                  title = L"(c) \; \tilde{\neg}(x \tilde{>} 0)",
                  xlabel = "x",
                  linestyle = [:solid :dash],
                  legend = false)
  p1, p2, p3
  end

plt = plot(plots...,
          layout = (1, 3),
          size = (700, 200),
          xticks = [-1, 0, 1],
          yticks = [0, 1],
          linewidth = 2,
          tickfontsize = 10)

savefig(plt, "negation.pdf")



f1(x, y) = err(x >ₛ y)
f2(x, y) = err(x <ₛ y)
f3(x, y) = err(x ==ₛ y)
x = y = range(-1, stop = 1, length = 100)
plots_srf = withkernel(kseα(10)) do
  surface(x, y, f1)
end
