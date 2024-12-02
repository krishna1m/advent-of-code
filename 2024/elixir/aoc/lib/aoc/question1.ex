defmodule Aoc.Question1 do
  def part1, do: part1(:real)
    Aoc.Input.testin()
  def part1(:test), do: part1_with(Aoc.Input.testin())
  def part1(:real), do: part1_with(Aoc.Input.realin())

  def part2, do: part2(:real)
    Aoc.Input.testin()
  def part2(:test), do: part2_with(Aoc.Input.testin())
  def part2(:real), do: part2_with(Aoc.Input.realin())

  def return_lists(input) do
    input
    |> String.split("\n")
    |> Enum.filter(& &1 =~ ~r(\s+))
    |> Enum.map(&String.split(&1, ~r(\s+)))
    |> Enum.reduce({[], []}, 
      fn [a, b], {x, y} -> 
        [a, b] = Enum.map([a, b], &String.to_integer/1)
        {[a | x], [b | y]}
      end)
  end

  def part1_with(input) do
    {x, y} = return_lists(input)

    Enum.zip(Enum.sort(x), Enum.sort(y))
    |> Enum.map(fn {a, b} -> abs(b - a) end)
    |> Enum.sum
  end

  def part2_with(input) do
    {x, y} = return_lists(input)
    counts = counter(y)
    Enum.reduce(x, 0, 
      fn num, acc ->
        acc + num * Map.get(counts, num, 0)
      end)
  end

  def counter(xs, count \\ %{})
  def counter([], count), do: count
  def counter([hd | tl], count) do
    counter(tl, Map.update(count, hd, 1, & &1 + 1))
  end
end
