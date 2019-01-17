  using RecipesBase
  using Plots.PlotMeasures

  @shorthands contourtriple

  @recipe function f(::Type{Val{:contourtriple}}, plt::AbstractPlot; density = false)
    x, y = plotattributes[:x], plotattributes[:y]
    bns = get(plotattributes, :bins, :auto)
    edges1, edges2 = Plots._hist_edges((x,y), bns)

    # set up the subplots
    legend --> false
    link := :both
    grid --> false
    layout --> @layout [
        tophist           _
        hist2d{0.9w,0.9h} righthist
    ]

    # main histogram2d
    @series begin
        seriestype := :histogram2d
        right_margin --> 0mm
        top_margin --> 0mm
        subplot := 2
        bins := (edges1, edges2)
    end

    # these are common to both marginal histograms
    ticks := nothing
    xlabel := ""
    ylabel := ""
    foreground_color_border := nothing
    fillcolor --> Plots.fg_color(plotattributes)
    linecolor --> Plots.fg_color(plotattributes)

    if density
        trim := true
        seriestype := :density
    else
        seriestype := :histogram
    end

    # upper histogram
    @series begin
        subplot := 1
        bottom_margin --> 0mm
        bins := edges1
        y := x
    end

    # right histogram
    @series begin
        orientation := :h
        subplot := 3
        left_margin --> 0mm
        bins := edges2
        y := y
    end
  end


  mt = MyType()
  plot(
      plot(mt),
      plot(mt, 100, linecolor = :red),
      plot(mt, marker = (:star,20), add_marker = false),
      plot(mt, add_marker = true)
  )