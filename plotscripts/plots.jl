using Omega
using Plots
using LaTeXStrings
using Plots.PlotMeasures

columnwidth = 7

## Negation 
soft(x) = "\tilde($x)" 

plots = withkernel(kseα(10)) do
  pred = x -> x > 0
  lg = [L"x \; \tilde{>} \; 0", L"x > 0"]
  p1 = Plots.plot([x -> err(x >ₛ 0), pred], -1, 1,
                  title = L"(a)",
                  xlabel = "x",
                  linestyle = [:solid :dot],
                  label = lg,
                  legend = :best)
  lg = [L"1 - (x \; \tilde{>} \; 0)", L"\neg(x > 0)"]
  # lg = [L"1 - (x \mathrel{\tilde{>}} 0)", L"\neg(x > 0)"]
  p2 = Plots.plot([x -> 1 - err(x >ₛ 0), !pred], -1, 1,
                  title = L"(b)",
                  xlabel = "x",
                  label = lg,
                  linestyle = [:solid :dot],
                  legend = :best)
  lg = [L"\tilde{\neg}(x \; \tilde{>} \; 0)", L"\neg(x > 0)"]
  p3 = Plots.plot([x-> err(!(x >ₛ 0)), !pred], -1, 1,
                  title = L"(c)",
                  xlabel = "x",
                  label = lg,
                  linestyle = [:solid :dot],
                  legend = :best)
  p1, p2, p3
  end

plt = plot(plots...,
          layout = (1, 3),
          size = (1400, 400),
          xticks = [-1, 0, 1],
          yticks = [0, 1],
          linewidth = 6,
          tickfontsize = 24,
          legendfontsize = 24,
          titlefontsize = 24,
          top_margin = 5mm)

savefig(plt, "negation.pdf")
