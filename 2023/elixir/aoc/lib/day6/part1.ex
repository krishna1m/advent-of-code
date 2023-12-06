defmodule Day6.Part1 do
  def main do
    contents = File.read!("resources/day6/input")
    times_distances = 
      contents 
      |> String.trim |> String.split("\n") 
      |> Enum.map(fn time_distance -> time_distance 
        |> String.split(":") |> tl |> hd |> String.trim |> String.split(~r"\s+") 
        |> Enum.map(&String.to_integer/1) 
      end) |> List.zip

    times_distances|> Enum.map(fn {time, record_distance} -> 
      (0..time) |> Enum.count(fn t -> 
        (time - t) * t > record_distance
      end)
    end) |> Enum.product

  end
end



