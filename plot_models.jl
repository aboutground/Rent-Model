using Makie
using GLMakie
using LinearAlgebra
using Optim

include("plot.jl")

mutable struct PlotSingleGood
    plot::Plot
    alpha::Float64
    P_M::Observable{Float64}
    D_0::Observable{Float64}
    D_100::Observable{Float64}
    M_100::Observable{Float64}
    F_100::Observable{Float64}
    d ::Observable{Function}
    m ::Observable{Function}
    f ::Observable{Function}
    s ::Observable{Function}
    E ::Observable{Point{2, Float64}}
    r ::Observable{Function}
    
    function PlotSingleGood(figure_position; alpha=0.3, P_M=80.0, D_0=90.0, D_100=20.0, M_100=30.0, F_100=70.0)
        plot = Plot(figure_position, title="Single Good", xlabel="Q", ylabel="P")
        Q_range = get_range(plot)

        P_M = Observable{Float64}(P_M) #market price
        D_0 = Observable{Float64}(D_0) #demand at 0
        D_100 = Observable{Float64}(D_100) #demand at 100
        M_100 = Observable{Float64}(M_100) #marginal cost at 100
        F_100 = Observable{Float64}(F_100) #freight cost at 100

        d = @lift(q -> min($P_M, $D_0 * ($D_100/$D_0)^(q/100)))
        m = @lift(q -> min($P_M, $M_100 * q / 100))
        f = @lift(q -> $F_100 * log(q + 1) / log(101))
        s = @lift(q -> $m(q) + $f(q))
        E = @lift(find_equilibrium($d, $s, Q_range))
        r = @lift(q -> $f(q) + ($d(100) < $s(100) ? ($E[2] - $f($E[1])) : $s(100) - $f(100)))

        @lift begin
            clear!(plot)
            add_line!(plot, $m, Q_range, color="cyan", label="Marginal Cost")
            add_line!(plot, $f, Q_range, color="green", label="Freight Cost")
            add_line!(plot, $d, Q_range, color="red", label="Demand")
            add_line!(plot, $s, Q_range, color="blue", label="Supply")
            add_line!(plot, $r, collect(plot.xlims[1]:1.0:$E[1]), color="lime", label="price - rent")
            add_line!(plot, $r, collect($E[1]:1.0:plot.xlims[2]), color="lime", linestyle=:dash)
            add_point!(plot, $E[1], $E[2], color="black", label="Equilibrium")
            add_vlines!(plot, $E, color="black", linestyle=:dash)
            add_hlines!(plot, $E, color="black", linestyle=:dash)
            add_axis_labels!(plot, $E[1], $E[2])
            E_range = collect(plot.xlims[1]:0.01:$E[1])
            add_band!(plot, $d, q -> $E[2], E_range, color="red", alpha=alpha, label="Consumer Surplus")
            add_band!(plot, q -> $E[2], $r, E_range, color="lime", alpha=alpha, label="Rent")
            add_band!(plot, $r, q -> $r(0), E_range, color="green", alpha=alpha, label="Transportation Cost")
            add_band!(plot, q -> $r(0), $m, E_range, color="blue", alpha=alpha, label="Producer Surplus")
            add_band!(plot, $m, q->0, E_range, color="cyan", alpha=alpha, label="Production Cost")
        end

        add_legend!(plot)
        return new(plot, alpha, P_M, D_0, D_100, M_100, F_100, d, m, f, s, E, r)
    end
end

function update_plot_single_good!(psg::PlotSingleGood; P_M=nothing, D_0=nothing, D_100=nothing, M_100=nothing, F_100=nothing)
    if P_M !== nothing; psg.P_M[] = P_M; end
    if D_0 !== nothing; psg.D_0[] = D_0; end
    if D_100 !== nothing; psg.D_100[] = D_100; end
    if M_100 !== nothing; psg.M_100[] = M_100; end  
    if F_100 !== nothing; psg.F_100[] = F_100; end
end

function find_equilibrium(D, S, Q_range)
    q_min, q_max = first(Q_range), last(Q_range)
    if q_min == q_max
        Q_e = q_min
        P_e = D(Q_e)
    elseif S(q_max) < D(q_max)
        Q_e = q_max
        P_e = D(Q_e)
    elseif S(q_min) > D(q_min)
        Q_e = q_min
        P_e = S(Q_e)
    else
        Q_e = Optim.minimizer(optimize(q -> abs(D(q) - S(q)), q_min, q_max))
        P_e = D(Q_e)
    end
    
    return Point{2, Float64}(Q_e, P_e)
end

mutable struct PlotMultipleGoods
    plot::Plot
    psgs::Observable{Vector{PlotSingleGood}}

    function PlotMultipleGoods(figure_position; psgs::Vector{PlotSingleGood})
        plot = Plot(figure_position, title="Multiple Goods", xlabel="Q", ylabel="P")
        Q_range = get_range(plot)
        psgs = Observable{Vector{PlotSingleGood}}(psgs)

        @lift begin
            clear!(plot)
            Q_range = get_range(plot)
            psgs_sorted = sort($psgs, by=psg -> psg.f[](1), rev=true)
            Q = 0.0
            Qs = [0.0 for _ in 1:length(psgs_sorted)]
            dQs = [0.0 for _ in 1:length(psgs_sorted)]
            
            for i in 1:length(psgs_sorted)
                d = q -> psgs_sorted[i].d[](q - Q)
                s = q -> psgs_sorted[i].m[](q - Q) + psgs_sorted[i].f[](q)
                range = collect(Q:0.01:plot.xlims[2])   
                if isempty(range)
                    E = Point{2, Float64}(Qs[i], 0.0)
                else
                    E = find_equilibrium(d, s, range)
                end
                Qs[i] = E[1]
                dQs[i] = E[1] - Q
                Q = E[1]
            end

            #find equilibrium by iterating through the Qs and updating the dQs
            error = 0
            count = 0
            while 1 < error || count < 2000
                count += 1
                Ps = [psgs_sorted[i].d[](dQs[i]) for i in 1:length(psgs_sorted)]
                Ms = [psgs_sorted[i].m[](dQs[i]) for i in 1:length(psgs_sorted)]
                F0s = [psgs_sorted[i].f[](1<i ? Qs[i-1] : 0.0) for i in 1:length(psgs_sorted)]
                F1s = [psgs_sorted[i].f[](Qs[i]) for i in 1:length(psgs_sorted)]
                R0s = Ps - F0s - Ms
                R1s = Ps - F1s - Ms

                #loop through Qs and Rs and update the error and the Qs 
                error = 0
                for i in 1:length(psgs_sorted)-1
                    error += abs(R1s[i] - R0s[i+1])
                    if R1s[i] < R0s[i+1]
                        dQs[i] -= 0.1
                        if dQs[i] < 0.0
                            dQs[i] = 0.0
                        end
                        dQs[i+1] += 0.1
                    else
                        dQs[i] += 0.1
                        dQs[i+1] -= 0.1
                        if dQs[i+1] < 0.0
                            dQs[i+1] = 0.0
                        end
                    end
                end
                Qs = cumsum(dQs)

                last_index = length(psgs_sorted)
                last_psgs = psgs_sorted[last_index]
                d = q -> last_psgs.d[](q - Qs[last_index-1])
                s = q -> last_psgs.m[](q - Qs[last_index-1]) + last_psgs.f[](q)   
                E = find_equilibrium(d, s, collect(Qs[last_index-1]:0.01:plot.xlims[2]))
                Qs[last_index] = min(E[1], plot.xlims[2])
                dQs[last_index] = Qs[last_index] - Qs[last_index-1]
            end

            #plot the lines and bands
            for i in 1:length(psgs_sorted) 
                E_range = collect(i == 1 ? (0.0:0.01:Qs[i]) : (Qs[i-1]:0.01:Qs[i]))

                d = q -> psgs_sorted[i].d[](q - (i == 1 ? 0.0 : Qs[i-1]))
                m = q -> psgs_sorted[i].m[](q - (i == 1 ? 0.0 : Qs[i-1]))
                f = q -> psgs_sorted[i].f[](q)
                s = q -> m(q) + f(q)
                r = q -> f(q) + s(Qs[i]) - f(Qs[i])

                if !isempty(E_range)
                    add_line!(plot, d, E_range, color="red", label="Demand")
                    add_line!(plot, m, E_range, color="cyan", label="Marginal Cost")
                    add_line!(plot, f, E_range, color="green", label="Freight Cost")
                    add_line!(plot, s, E_range, color="blue", label="Supply")
                    add_line!(plot, r, E_range, color="lime", label="price - rent")
                end
                add_line!(plot, f, Q_range, color="green", linestyle=:dash)

                Q_e = Qs[i]
                P_e = d(Q_e)
                add_point!(plot, Q_e, P_e, color="black", label="Equilibrium")
                add_vlines!(plot, Point{2, Float64}(Q_e, plot.ylims[2]), color="black", linestyle=:dash)
                add_hlines!(plot, Point{2, Float64}(Q_e, P_e), color="black", linestyle=:dash)
                add_axis_labels!(plot, Q_e, P_e)

                alpha = psgs_sorted[i].alpha[]
                add_band!(plot, d, q -> P_e, E_range, color="red", alpha=alpha, label="Consumer Surplus")
                add_band!(plot, q -> P_e, r, E_range, color="lime", alpha=alpha, label="Rent")
                add_band!(plot, r, q -> r(0), E_range, color="green", alpha=alpha, label="Transportation Cost")
                add_band!(plot, q -> r(0), m, E_range, color="blue", alpha=alpha, label="Producer Surplus")
                add_band!(plot, m, q->0, E_range, color="cyan", alpha=alpha, label="Production Cost")
            end
        end
        return new(plot, psgs)
    end
end

function update_plot_multiple_goods!(pmg::PlotMultipleGoods; psgs::Vector{PlotSingleGood})
    if psgs !== nothing; pmg.psgs[] = psgs; end
end