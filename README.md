[![Build Status](https://github.com/MartinuzziFrancesco/CellularAutomata.jl/workflows/CI/badge.svg)](https://github.com/MartinuzziFrancesco/CellularAutomata.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/MartinuzziFrancesco/CellularAutomata.jl/coverage.svg?branch=master)](https://codecov.io/gh/MartinuzziFrancesco/CellularAutomata.jl?branch=master)

# CellularAutomata
One dimensional cellular automata creation and analysis tools

## Installation

```julia
julia> using Pkg
julia> Pkg.add("https://github.com/MartinuzziFrancesco/CellularAutomata.jl")
```

## Discrete Cellular Automata
The package offers creation of all the cellular automata described in A New Kind of Science by Wolfram, and the rules for the creation are labelled as in the book.
We will recreate some of the examples that can be found in the [wolfram atlas](http://atlas.wolfram.com/TOC/TOC_200.html) both for elementary and totalistic cellular automata.

### Elementary Cellular Automata

Let's try and reproduce a couple of rules.

[Rule 18](http://atlas.wolfram.com/01/01/18/)

```julia
using CellularAutomata, Plots

states = 2
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Bool, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 18

ca = CellularAutomaton(DCA(rule), starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```
![dca18](https://user-images.githubusercontent.com/10376688/75625854-4a816b00-5bc2-11ea-8337-9132553cd38b.png)

[Rule 30](http://atlas.wolfram.com/01/01/30/)

```julia
states = 2
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Bool, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 30

ca = CellularAutomaton(DCA(rule), starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```
![dca30](https://user-images.githubusercontent.com/10376688/75625882-874d6200-5bc2-11ea-904a-e6658aab8403.png)

### Totalistic Cellular Automata

For elementary cellular automata we only dealt with states = 2. For the totalistic case we are going to shown results for 3 and 4 states.

[Rule 1635](http://atlas.wolfram.com/01/02/1635/)

```julia
states = 3
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 1635

ca = CellularAutomaton(DCA(rule, states=states), starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```
![dca1635](https://user-images.githubusercontent.com/10376688/75628258-7eb35680-5bd7-11ea-81c5-b95b25f1369d.png)

[Rule 107398](http://atlas.wolfram.com/01/03/107398/)

```julia
states = 4
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 107398

ca = CellularAutomaton(DCA(rule, states=states), starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

![dca107398](https://user-images.githubusercontent.com/10376688/75628292-cd60f080-5bd7-11ea-93c7-66277b0b6bd6.png)

Now let's also show some results for a bigger radius, using a radius of 2 as an example.

[Rule 53](http://atlas.wolfram.com/01/06/Rules/53/index.html#01_06_9_53)

```julia
states = 2
radius = 2
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 53

ca = CellularAutomaton(DCA(rule, radius=radius), starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

![dca53r2](https://user-images.githubusercontent.com/10376688/136658595-0c860395-9a0d-4df2-ac4d-2ed85bd2927c.png)

## Continuous Cellular Automata

In this case we deal with a continuous set of values. The examples are taken from the already mentioned book [NKS](https://www.wolframscience.com/nks/p159--continuous-cellular-automata/).

Rule 0.025

```julia
generations = 50
ncells = 111
starting_val = zeros(Float64, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1.0

rule = 0.025

ca = CellularAutomaton(CCA(rule), starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

![cca0025](https://user-images.githubusercontent.com/10376688/75628344-5f68f900-5bd8-11ea-8941-892c14036f37.png)


Rule 0.2

```julia
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Float64, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1.0

rule = 0.2

ca = CellularAutomaton(CCA(rule, radius=radius), starting_val, generations) #CCA(rule, radius=1) is default

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

![cca02](https://user-images.githubusercontent.com/10376688/75628407-ed44e400-5bd8-11ea-95c4-d7a5a569923c.png)

## To do list
- [x] Only radius possible is 1. Need to extend that
- [ ] Documentation
- [ ] Entropy functions and such
- [x] Async neighborhoods (CCA is missing. can't find any xample of async cca atm)
- [ ] Better tests

