using Pkg
Pkg.activate(".")
Pkg.instantiate()
using Makie
using GLMakie
using LinearAlgebra
using Optim

# Try to activate GLMakie, fall back to CairoMakie if it fails
try
    GLMakie.activate!()
    println("Using GLMakie for interactive plots")
catch e
    println("GLMakie failed, falling back to CairoMakie: ", e)
    using CairoMakie
    CairoMakie.activate!()
end

# Include the new Plot models
include("plot_models.jl")

# Create one comprehensive figure - larger to accommodate 3 goods
fig = Figure(size=(1350, 1000))

# Create slider control panel on the right side for Good 1
Label(fig[1, 5], "Good 1 Controls", fontsize=14, tellwidth=false, halign=:center)
grid_0 = GridLayout(fig[1, 5])
Label(grid_0[1, 1], "P_M", fontsize=10, tellwidth=false, halign=:center)
Label(grid_0[1, 2], "D₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_0[1, 3], "D₁₀₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_0[1, 4], "M₁₀₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_0[1, 5], "F₁₀₀", fontsize=10, tellwidth=false, halign=:center)
slider_P_M_0 = Slider(grid_0[2, 1], range=0:1:100, startvalue=40, height=150, horizontal=false)
slider_D0_0 = Slider(grid_0[2, 2], range=0:1:100, startvalue=90, height=150, horizontal=false)
slider_D100_0 = Slider(grid_0[2, 3], range=0:1:100, startvalue=30, height=150, horizontal=false)
slider_M100_0 = Slider(grid_0[2, 4], range=0:1:100, startvalue=75, height=150, horizontal=false)
slider_F100_0 = Slider(grid_0[2, 5], range=0:1:100, startvalue=15, height=150, horizontal=false)

# Good 2 controls
Label(fig[2, 5], "Good 2 Controls", fontsize=14, tellwidth=false, halign=:center)
grid_1 = GridLayout(fig[2, 5])
Label(grid_1[1, 1], "P_M", fontsize=10, tellwidth=false, halign=:center)
Label(grid_1[1, 2], "D₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_1[1, 3], "D₁₀₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_1[1, 4], "M₁₀₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_1[1, 5], "F₁₀₀", fontsize=10, tellwidth=false, halign=:center)
slider_P_M_1 = Slider(grid_1[2, 1], range=0:1:100, startvalue=75, height=150, horizontal=false)
slider_D0_1 = Slider(grid_1[2, 2], range=0:1:100, startvalue=70, height=150, horizontal=false)
slider_D100_1 = Slider(grid_1[2, 3], range=0:1:100, startvalue=10, height=150, horizontal=false)
slider_M100_1 = Slider(grid_1[2, 4], range=0:1:100, startvalue=95, height=150, horizontal=false)
slider_F100_1 = Slider(grid_1[2, 5], range=0:1:100, startvalue=55, height=150, horizontal=false)

# Good 3 controls
Label(fig[3, 5], "Good 3 Controls", fontsize=14, tellwidth=false, halign=:center)
grid_2 = GridLayout(fig[3, 5])
Label(grid_2[1, 1], "P_M", fontsize=10, tellwidth=false, halign=:center)
Label(grid_2[1, 2], "D₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_2[1, 3], "D₁₀₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_2[1, 4], "M₁₀₀", fontsize=10, tellwidth=false, halign=:center)
Label(grid_2[1, 5], "F₁₀₀", fontsize=10, tellwidth=false, halign=:center)
slider_P_M_2 = Slider(grid_2[2, 1], range=0:1:100, startvalue=85, height=150, horizontal=false)
slider_D0_2 = Slider(grid_2[2, 2], range=0:1:100, startvalue=90, height=150, horizontal=false)
slider_D100_2 = Slider(grid_2[2, 3], range=0:1:100, startvalue=20, height=150, horizontal=false)
slider_M100_2 = Slider(grid_2[2, 4], range=0:1:100, startvalue=85, height=150, horizontal=false)
slider_F100_2 = Slider(grid_2[2, 5], range=0:1:100, startvalue=5, height=150, horizontal=false)

# Create PlotSingleGood instances with figure positions
psg0 = PlotSingleGood(fig[1, 1], 
    alpha=0.2,
    P_M=slider_P_M_0.value[],
    D_0=slider_D0_0.value[], 
    D_100=slider_D100_0.value[], 
    M_100=slider_M100_0.value[], 
    F_100=slider_F100_0.value[])
psg1 = PlotSingleGood(fig[1, 2], 
    alpha=0.3,
    P_M=slider_P_M_1.value[],
    D_0=slider_D0_1.value[], 
    D_100=slider_D100_1.value[], 
    M_100=slider_M100_1.value[], 
    F_100=slider_F100_1.value[])
psg2 = PlotSingleGood(fig[1, 3],
    alpha=0.4,
    P_M=slider_P_M_2.value[],
    D_0=slider_D0_2.value[], 
    D_100=slider_D100_2.value[], 
    M_100=slider_M100_2.value[], 
    F_100=slider_F100_2.value[])

# Multiple goods plot spans across the bottom
pmg = PlotMultipleGoods(fig[2:3, 1:3], psgs=[psg0, psg1, psg2])

# Set column widths for better proportions
colsize!(fig.layout, 1, Relative(0.25))  # Good 1 plot
colsize!(fig.layout, 2, Relative(0.25))  # Good 2 plot
colsize!(fig.layout, 3, Relative(0.25))  # Good 3 plot
colsize!(fig.layout, 4, Fixed(80))       # Control labels
colsize!(fig.layout, 5, Fixed(200))      # Sliders

# Set row heights
rowsize!(fig.layout, 1, Relative(0.35))  # Individual plots
rowsize!(fig.layout, 2, Relative(0.325)) # Combined plot (top half)
rowsize!(fig.layout, 3, Relative(0.325)) # Combined plot (bottom half)

# Connect Good 1 sliders
on(slider_P_M_0.value) do val
    update_plot_single_good!(psg0, P_M=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_D0_0.value) do val
    # Clamp D100 slider value to not exceed D0 value
    if slider_D100_0.value[] > val
        set_close_to!(slider_D100_0, val)
    end
    
    update_plot_single_good!(psg0, D_0=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_D100_0.value) do val
    # Ensure D100 doesn't exceed D0
    clamped_val = min(val, slider_D0_0.value[])
    if clamped_val != val
        set_close_to!(slider_D100_0, clamped_val)
        return
    end
    
    update_plot_single_good!(psg0, D_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_M100_0.value) do val
    update_plot_single_good!(psg0, M_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_F100_0.value) do val
    update_plot_single_good!(psg0, F_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

# Connect Good 2 sliders
on(slider_P_M_1.value) do val
    update_plot_single_good!(psg1, P_M=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_D0_1.value) do val
    # Clamp D100 slider value to not exceed D0 value
    if slider_D100_1.value[] > val
        set_close_to!(slider_D100_1, val)
    end
    
    update_plot_single_good!(psg1, D_0=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_D100_1.value) do val
    # Ensure D100 doesn't exceed D0
    clamped_val = min(val, slider_D0_1.value[])
    if clamped_val != val
        set_close_to!(slider_D100_1, clamped_val)
        return
    end
    
    update_plot_single_good!(psg1, D_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_M100_1.value) do val
    update_plot_single_good!(psg1, M_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_F100_1.value) do val
    update_plot_single_good!(psg1, F_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

# Connect Good 3 sliders
on(slider_P_M_2.value) do val
    update_plot_single_good!(psg2, P_M=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_D0_2.value) do val
    # Clamp D100 slider value to not exceed D0 value
    if slider_D100_2.value[] > val
        set_close_to!(slider_D100_2, val)
    end
    
    update_plot_single_good!(psg2, D_0=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_D100_2.value) do val
    # Ensure D100 doesn't exceed D0
    clamped_val = min(val, slider_D0_2.value[])
    if clamped_val != val
        set_close_to!(slider_D100_2, clamped_val)
        return
    end
    
    update_plot_single_good!(psg2, D_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_M100_2.value) do val
    update_plot_single_good!(psg2, M_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

on(slider_F100_2.value) do val
    update_plot_single_good!(psg2, F_100=val)
    update_plot_multiple_goods!(pmg, psgs=[psg0, psg1, psg2])
end

display(fig)
