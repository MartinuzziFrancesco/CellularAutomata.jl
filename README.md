[![Build Status](https://github.com/MartinuzziFrancesco/CellularAutomata.jl/workflows/CI/badge.svg)](https://github.com/MartinuzziFrancesco/CellularAutomata.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/MartinuzziFrancesco/CellularAutomata.jl/coverage.svg?branch=master)](https://codecov.io/gh/MartinuzziFrancesco/CellularAutomata.jl?branch=master)
[![DOI](https://zenodo.org/badge/244027385.svg)](https://zenodo.org/badge/latestdoi/244027385)



# CellularAutomata
Cellular automata creation and analysis tools

## Installation
CellularAutomata.jl is registered on the general registry. For the installation follow:

```julia
julia> using Pkg
julia> Pkg.add("CellularAutomata")
```
or, if you prefer:
 
```julia
julia> using Pkg
julia> Pkg.add("https://github.com/MartinuzziFrancesco/CellularAutomata.jl")
```

## Discrete Cellular Automata
The package offers creation of all the cellular automata described in A New Kind of Science by Wolfram, and the rules for the creation are labelled as in the book.
We will recreate some of the examples that can be found in the [wolfram atlas](http://atlas.wolfram.com/TOC/TOC_200.html) both for elementary and totalistic cellular automata.

### Elementary Cellular Automata

Elementary Cellular Automata (ECA) have a radius of one and can be in only two possible states. Here we show a couple of examples:

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
using CellularAutomata, Plots

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

### General Cellular Automata

General Cellular Automata have the same rule of ECA but they can have a radius larger than unity and/or a number of states greater than two. Here are provided examples for every possible permutation, starting with a Cellular Automaton with 3 states.

[Rule 7110222193934](https://www.wolframalpha.com/input/?i=rule+7%2C110%2C222%2C193%2C934+k%3D3&lk=3)
```julia
using CellularAutomata, Plots

states = 3
radius = 1
generations = 50
ncells = 111
starting_val = zeros(ncells)
starting_val[Int(floor(ncells/2)+1)] = 2

rule = 7110222193934 

ca = CellularAutomaton(DCA(rule,states=states,radius=radius), 
                       starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false,
    size=(ncells*10, generations*10))
```
![dca7110222193934](https://user-images.githubusercontent.com/10376688/137601771-3ee335ab-4334-4250-9a48-679b206009be.png)

The following examples shows a Cellular Automaton with radius=2, with two only possible states:

[Rule 1388968789](https://www.wolframalpha.com/input/?i=rule+1%2C388%2C968%2C789+r%3D2&lk=3)

```julia
using CellularAutomata, Plots

states = 2
radius = 2
generations = 30
ncells = 111
starting_val = zeros(ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 1388968789 

ca = CellularAutomaton(DCA(rule,states=states,radius=radius), 
                           starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false,
    size=(ncells*10, generations*10))
```

![dca1388968789](https://user-images.githubusercontent.com/10376688/137601749-3ccfe90d-b847-4401-93a5-076db48b5954.png)

And finally, three states with a radius equal to two:

[Rule 914752986721674989234787899872473589234512347899](https://www.wolframalpha.com/input/?i=CA+k%3D3+r%3D2+rule+914752986721674989234787899872473589234512347899&lk=3)

```julia
using CellularAutomata, Plots

states = 3
radius = 2
generations = 30
ncells = 111
starting_val = zeros(ncells)
starting_val[Int(floor(ncells/2)+1)] = 2

rule = 914752986721674989234787899872473589234512347899 

ca = CellularAutomaton(DCA(rule,states=states,radius=radius), 
                       starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false,
    size=(ncells*10, generations*10))
```
![dca914752986721674989234787899872473589234512347899](https://user-images.githubusercontent.com/10376688/137601733-aabc0b7b-8769-474b-885a-1e9d90c62696.png)

It is also possible to specify asymmetric neighborhoods, giving a tuple to the kwarg detailing the number of neighbors to considerate at the left and right of the cell:
[Rule 1235](https://www.wolframalpha.com/input/?i=radius+3%2F2+rule+1235&lk=3)

```julia
using CellularAutomata, Plots

states = 2
radius = (2,1)
generations = 30
ncells = 111
starting_val = zeros(ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 1235 

ca = CellularAutomaton(DCA(rule,states=states,radius=radius), 
                       starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false,
    size=(ncells*10, generations*10))
```

![dca1235](https://user-images.githubusercontent.com/10376688/137601708-7f204735-eba0-4b83-8b65-cc4d0ceb0fb6.png)

### Totalistic Cellular Automata

Totalistic Cellular Automata takes the sum of the neighborhood to calculate the value of the next step.

[Rule 1635](http://atlas.wolfram.com/01/02/1635/)

```julia
using CellularAutomata, Plots

states = 3
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 1635

ca = CellularAutomaton(TCA(rule, states=states), 
                       starting_val, generations)

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
using CellularAutomata, Plots

states = 4
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 107398

ca = CellularAutomaton(TCA(rule, states=states), 
                       starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

![dca107398](https://user-images.githubusercontent.com/10376688/75628292-cd60f080-5bd7-11ea-93c7-66277b0b6bd6.png)

Here are some results for a bigger radius, using a radius of 2 as an example.

[Rule 53](http://atlas.wolfram.com/01/06/Rules/53/index.html#01_06_9_53)

```julia
using CellularAutomata, Plots

states = 2
radius = 2
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 53

ca = CellularAutomaton(TCA(rule, radius=radius), 
                           starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

![dca53r2](https://user-images.githubusercontent.com/10376688/136658595-0c860395-9a0d-4df2-ac4d-2ed85bd2927c.png)

## Continuous Cellular Automata

Continuous Cellular Automata work in the same way as the totalistic but with real values. The examples are taken from the already mentioned book [NKS](https://www.wolframscience.com/nks/p159--continuous-cellular-automata/).

Rule 0.025

```julia
using CellularAutomata, Plots

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
using CellularAutomata, Plots

radius = 1
generations = 50
ncells = 111
starting_val = zeros(Float64, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1.0

rule = 0.2

ca = CellularAutomaton(CCA(rule, radius=radius), 
                       starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

![cca02](https://user-images.githubusercontent.com/10376688/75628407-ed44e400-5bd8-11ea-95c4-d7a5a569923c.png)

## Game of Life

This package can also reproduce Conway's Game of Life, and any variation based on it. The ```Life()``` function takes in a tuple containing the number of neighbors that will gave birth to a new cell, or that will make an existing cell survive. (For example in the Conways's Life the tuple (3, (2,3)) indicates having 3 live neighbors will give birth to an otherwise dead cell, and having either 2 or 3 lie neighbors will make an alive cell continue living.) The implementation follows the [Golly](http://golly.sourceforge.net/Help/changes.html) notation.

This script reproduces the famous glider:

```julia
using CellularAutomata, Plots

glider = [[0, 0, 1, 0, 0] [0, 0, 0, 1, 0] [0, 1, 1, 1, 0]]

space = zeros(Bool, 30, 30)
insert = 1
space[insert:insert+size(glider, 1)-1, insert:insert+size(glider, 2)-1] = glider
gens = 100
space_gliding = CellularAutomaton(Life((3, (2,3))), space, gens)

anim = @animate for i = 1:gens
    heatmap(space_gliding.evolution[:,:,i], 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    size=(1080,1080),
    axis=false,
    ticks=false)
end
 
gif(anim, "glider.gif", fps = 15)
```
![glider](https://user-images.githubusercontent.com/10376688/137601901-97940211-f6e7-4ab1-9eee-325165000fd4.gif)

