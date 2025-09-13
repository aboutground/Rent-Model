# Three Goods Economic Model

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/robbedemey/Rent-Model/main?urlpath=lab/tree/three_goods.jl)

An interactive economic model for analyzing three goods with demand-supply equilibrium, freight costs, and consumer/producer surplus visualization.

## 🚀 Quick Start

**Try it online**: Click the "launch binder" badge above to run the model in your browser - no installation required!

**Run locally**:
1. Install Julia from [julialang.org](https://julialang.org/downloads/)
2. Clone this repository
3. Open Julia in the project directory and run:
   ```julia
   julia three_goods.jl
   ```

## 📊 Features

- **Interactive Three-Good Model**: Analyze three different goods simultaneously
- **Real-time Parameter Control**: 
  - Market Price (P_M)
  - Demand at 0 and 100 (D₀, D₁₀₀)
  - Marginal Cost at 100 (M₁₀₀)
  - Freight Cost at 100 (F₁₀₀)
- **Smart Constraints**: D₁₀₀ automatically clamped to not exceed D₀
- **Economic Visualizations**:
  - Individual demand/supply curves for each good
  - Equilibrium points with reference lines
  - Consumer surplus, producer surplus, and rent areas
  - Combined multi-good analysis
- **Professional Plots**: Clean, publication-ready economic graphs

## 🎛️ Interactive Controls

Each good has 5 sliders:
- **P_M**: Market price ceiling
- **D₀**: Demand intercept (maximum willingness to pay)
- **D₁₀₀**: Demand at quantity 100 (automatically limited by D₀)
- **M₁₀₀**: Marginal cost at quantity 100
- **F₁₀₀**: Freight cost at quantity 100

## 📈 Economic Model

**Demand Function**: `P = min(P_M, D₀ × (D₁₀₀/D₀)^(q/100))`

**Supply Function**: `P = Marginal_Cost + Freight_Cost`
- Marginal Cost: `M₁₀₀ × q/100`
- Freight Cost: `F₁₀₀ × log(q+1)/log(101)`

**Equilibrium**: Automatically calculated where demand meets supply

## 🔧 Technical Details

- **Language**: Julia 1.8+
- **Plotting**: Makie.jl with GLMakie backend
- **Optimization**: Optim.jl for equilibrium finding
- **Interface**: Interactive sliders with real-time updates

## 📁 Files

- `three_goods.jl` - Main interactive application
- `plot_models.jl` - Economic plotting and modeling functions  
- `plot.jl` - Base plotting utilities
- `Project.toml` - Julia package dependencies

## 🌐 Web Deployment

This model is designed to run on [MyBinder.org](https://mybinder.org) for free web access. Simply:

1. Fork this repository on GitHub
2. Update the Binder badge URL with your username/repo
3. Share the Binder link for instant access

## 🎓 Educational Use

Perfect for:
- Economics courses (microeconomics, industrial organization)
- Understanding supply-demand dynamics
- Visualizing economic surplus concepts
- Exploring multi-market interactions
- Teaching equilibrium analysis

## 🤝 Contributing

Feel free to:
- Add more goods to the model
- Implement different demand/supply functions
- Add time dynamics
- Include market interaction effects
- Enhance visualizations

## 📄 License

Open source - feel free to use and modify for educational purposes.