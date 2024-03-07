# One Dimensional Cellular Automata

## Elementary Cellular Automata
Elementary Cellular Automata (ECA) have a radius of one and can be in only two possible states. Here we show a couple of examples:

[Rule 18](http://atlas.wolfram.com/01/01/18/)

```@example eca
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

[Rule 30](http://atlas.wolfram.com/01/01/30/)

```@example eca
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

## Multiple States Cellular Automata
General Cellular Automata have the same rule of ECA but they can have a radius larger than unity and/or a number of states greater than two. Here are provided examples for every possible permutation, starting with a Cellular Automaton with 3 states.

[Rule 7110222193934](https://www.wolframalpha.com/input/?i=rule+7%2C110%2C222%2C193%2C934+k%3D3&lk=3)
```@example msca
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

## Larger Radius Cellular Automata
The following examples shows a Cellular Automaton with radius=2, with two only possible states:

[Rule 1388968789](https://www.wolframalpha.com/input/?i=rule+1%2C388%2C968%2C789+r%3D2&lk=3)

```@example lrca
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

And finally, three states with a radius equal to two:

[Rule 914752986721674989234787899872473589234512347899](https://www.wolframalpha.com/input/?i=CA+k%3D3+r%3D2+rule+914752986721674989234787899872473589234512347899&lk=3)

```@example lrca
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

It is also possible to specify asymmetric neighborhoods, giving a tuple to the kwarg detailing the number of neighbors to considerate at the left and right of the cell:
[Rule 1235](https://www.wolframalpha.com/input/?i=radius+3%2F2+rule+1235&lk=3)

```@example lrca
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

## Totalistic Cellular Automata

Totalistic Cellular Automata takes the sum of the neighborhood to calculate the value of the next step.

[Rule 1635](http://atlas.wolfram.com/01/02/1635/)

```@example tca
using CellularAutomata, Plots
states = 3
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 1635

ca = CellularAutomaton(DCA(rule, states=states), 
                       starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

[Rule 107398](http://atlas.wolfram.com/01/03/107398/)

```@example tca
states = 4
radius = 1
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 107398

ca = CellularAutomaton(DCA(rule, states=states), 
                       starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

Here are some results for a bigger radius, using a radius of 2 as an example.

[Rule 53](http://atlas.wolfram.com/01/06/Rules/53/index.html#01_06_9_53)

```julia
states = 2
radius = 2
generations = 50
ncells = 111
starting_val = zeros(Integer, ncells)
starting_val[Int(floor(ncells/2)+1)] = 1

rule = 53

ca = CellularAutomaton(DCA(rule, radius=radius), 
                           starting_val, generations)

heatmap(ca.evolution, 
    yflip=true, 
    c=cgrad([:white, :black]),
    legend = :none,
    axis=false,
    ticks=false)
```

## Continuous Cellular Automata

Continuous Cellular Automata work in the same way as the totalistic but with real values. The examples are taken from the already mentioned book [NKS](https://www.wolframscience.com/nks/p159--continuous-cellular-automata/).

Rule 0.025

```@example cca
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

Rule 0.2

```@example cca
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
