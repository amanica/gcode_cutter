
function modify_gcode(input_file::AbstractString, first_layer::Float64, last_layer::Float64, output_file::AbstractString)
    # Read the input G-code file
    input_lines = readlines(input_file)
    @show first_layer, last_layer

    # Find the index of the M107 command
    @show m107_index = findfirst(line -> occursin(r"M107", line), input_lines)

    # Retain lines until M107
    retained_lines = input_lines[1:m107_index]

    filtered_lines = input_lines[m107_index+1:end]

    # Find the indices of the first and last layers
    @show first_layer_index = findfirst(line -> begin
            m = match(r"G1\s+Z([0-9.]+)", line)
            if m !== nothing
                z_height = parse(Float64, m.captures[1])
                return z_height >= first_layer
            end
            return false
        end, filtered_lines)
    @show last_layer_index = findfirst(line -> begin
            m = match(r"G1\s+Z([0-9.]+)", line)
            if m !== nothing
                z_height = parse(Float64, m.captures[1])
                return z_height > last_layer
            end
            return false
        end, filtered_lines[first_layer_index+1:end])+first_layer_index

    # Remove lines between first_layer and last_layer (inclusive)
    deleteat!(filtered_lines, first_layer_index:last_layer_index)

    # Calculate the difference between the layer heights
    layer_height_difference = last_layer - first_layer

    # Adjust Z values in remaining G1 commands after M107
    adjusted_lines = map(line -> begin
            if occursin(r"G1", line) && occursin(r"Z", line)
                m = match(r"Z([0-9.]+)", line)
                if m !== nothing
                    z_height = parse(Float64, m.captures[1])
                    if z_height > first_layer
                        z_height -= layer_height_difference
                        z_height = round(z_height, digits=3)  # Round to 3 decimal places
                        line = replace(line, r"Z([0-9.]+)" => "Z$z_height")
                    end
                end
            end
            return line
        end, filtered_lines)

    # Concatenate retained lines and adjusted lines
    modified_lines = vcat(retained_lines, adjusted_lines)

    # Convert modified lines to a string
    output_string = join(modified_lines, "\n")

    # Save the modified G-code to the output file
    write(output_file, output_string)
end

# Get parameters from command line
input_file = ARGS[1]
first_layer_height = parse(Float64, ARGS[2])
last_layer_height = parse(Float64, ARGS[3])
output_file = "cut_$(first_layer_height)_$(last_layer_height)_$input_file"

# Example usage: julia gcode_cutter.jl input.gcode 0.2 2.0
modify_gcode(input_file, first_layer_height, last_layer_height, output_file)
