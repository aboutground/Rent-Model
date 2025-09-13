using Makie
using GLMakie
using LinearAlgebra

mutable struct Plot
    ax::Axis
    title::String
    xlabel::String
    ylabel::String
    xlims::Tuple{Float64, Float64}
    ylims::Tuple{Float64, Float64}
    
    function Plot(figure_position; 
                   title::String="Plot",
                   xlabel::String="X",
                   ylabel::String="Y",
                   xlims::Tuple{Float64, Float64}=(0.0, 100.0),
                   ylims::Tuple{Float64, Float64}=(0.0, 100.0))
        ax = Axis(figure_position, 
            title=title,
            xlabel=xlabel, 
            ylabel=ylabel,
            xlabelsize=12, 
            ylabelsize=12,
            xticklabelsize=10, 
            yticklabelsize=10,
            xticksize=1, 
            yticksize=1)
        xlims!(ax, xlims[1], xlims[2])
        ylims!(ax, ylims[1], ylims[2])
        deactivate_interaction!(ax, :rectanglezoom)
        return new(ax, title, xlabel, ylabel, xlims, ylims)
    end
end

function get_range(plot::Plot)
    return collect(plot.xlims[1]:0.01:plot.xlims[2])
end

function add_line!(plot::Plot, f::Function, x_range::Vector{Float64}; kwargs...)
    y_data = Float64[f(x) for x in x_range]
    return lines!(plot.ax, x_range, y_data; linewidth=2.0, kwargs...)
end

function add_point!(plot::Plot, x::Float64, y::Float64; kwargs...)
    return scatter!(plot.ax, [x], [y]; markersize=10.0, kwargs...)
end

function add_band!(plot::Plot, f1::Function, f2::Function, x_range::Vector{Float64}; color::String="black", kwargs...)
    y0_data = Float64[f1(x) for x in x_range]
    y1_data = Float64[f2(x) for x in x_range]
    return band!(plot.ax, x_range, y0_data, y1_data; color=(Symbol(color), 0.3), kwargs...)
end

function add_vlines!(plot::Plot, point::Point{2, Float64}; color::String="gray", linestyle::Symbol=:solid)
    return lines!(plot.ax, [point[1], point[1]], [0.0, point[2]], color=color, linestyle=linestyle, alpha=1.0)
end

function add_hlines!(plot::Plot, point::Point{2, Float64}; color::String="gray", linestyle::Symbol=:solid)
    return lines!(plot.ax, [0.0, point[1]], [point[2], point[2]], color=color, linestyle=linestyle, alpha=1.0)
end

function add_legend!(plot::Plot)
    return axislegend(plot.ax, 
        labelsize=10,           # Smaller font size for legend text
        framewidth=1,           # Thinner frame around legend
        patchsize=(15, 15),     # Smaller legend markers/patches
        rowgap=2,               # Smaller gap between legend rows
        colgap=8,               # Smaller gap between legend columns
        padding=(4, 4, 4, 4))   # Smaller padding around legend
end

function clear!(plot::Plot)
    empty!(plot.ax)
    return nothing
end