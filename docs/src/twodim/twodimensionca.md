# Two Dimensional Cellular Automata

## Game of Life

This package can also reproduce Conway's Game of Life, and any variation based on it. The ```Life()``` function takes in a tuple containing the number of neighbors that will gave birth to a new cell, or that will make an existing cell survive. (For example in the Conways's Life the tuple (3, (2,3)) indicates having 3 live neighbors will give birth to an otherwise dead cell, and having either 2 or 3 lie neighbors will make an alive cell continue living.) The implementation follows the [Golly](http://golly.sourceforge.net/Help/changes.html) notation.

This script reproduces the famous glider:

```@example life
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
