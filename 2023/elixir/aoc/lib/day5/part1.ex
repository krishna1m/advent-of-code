defmodule Day5.Part1 do
  def transform(map_line) do
    map_line |> String.split(":") |> tl |> hd |> String.trim |> String.split("\n") |> Enum.map(fn numbers -> String.split(numbers, " ") |> Enum.map(&String.to_integer/1) end)
  end

  def get_value(key, map) do
    value_or_false = 
      map |> Enum.map(fn [dest, source, range] ->
        cond do
          key >= source and key <= source + range - 1 ->
            offset = key - source
            dest + offset
          true ->
            false
        end
      end)

    case value_or_false |> Enum.all?(fn boolean_or_val -> boolean_or_val == false end) do
      true -> 
        key
      false ->
        value_or_false |> Enum.find(fn boolean_or_val -> boolean_or_val != false end)
    end
  end

  def main do
    contents = File.read!("resources/day5/input-test")
    [seeds_list, seed_soil_map, soil_fertilizer_map, fertilizer_water_map, water_light_map, light_temp_map, temp_humidity_map, humidity_location_map] = 
      contents |> String.split("\n\n")
    seeds_list = seeds_list |> String.split(":") |> tl |> hd |> String.trim |> String.split(" ") |> Enum.map(&String.to_integer/1)
    seed_soil_map = transform(seed_soil_map)
    soil_fertilizer_map = transform(soil_fertilizer_map)
    fertilizer_water_map = transform(fertilizer_water_map)
    water_light_map = transform(water_light_map)
    light_temp_map = transform(light_temp_map)
    temp_humidity_map = transform(temp_humidity_map)
    humidity_location_map = transform(humidity_location_map)

    required_value = 
      seeds_list |> Enum.map(fn seed ->
        seed |> 
        get_value(seed_soil_map) |>
        get_value(soil_fertilizer_map) |>
        get_value(fertilizer_water_map) |>
        get_value(water_light_map) |>
        get_value(light_temp_map) |>
        get_value(temp_humidity_map) |>
        get_value(humidity_location_map)
      end) |> Enum.min
    IO.inspect required_value
  end
end


