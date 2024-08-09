# Overview
A simple tool to cut out a part of gcode - mainly to finish a 3dprint that got interrupted..

I could not find this functionality in `RepetierHost` or `PrusaSlicer` so I had to make this
so that I don't have to re-print a whole print where my filament jammed when about three quarters done :'(
(I did originally use the `PrusaSlicer` functionality to create the gcode but I used connectors etc, so I can't re-create the same gcode, so I needed to modify the gcode that I have already).

# Install
You need to install [Julia](https://julialang.org/downloads/).
Download [the script](https://github.com/amanica/gcode_cutter/blob/main/gcode_cutter.jl) or clone [this repo](https://github.com/amanica/gcode_cutter.git).

# Usage
Say your print failed at 20mm but you want to keep the original first layer (0.2mm in my case) then you can use:
`julia gcode_cutter.jl input.gcode 0.2 20.0 output.gcode`