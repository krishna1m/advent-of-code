defmodule AocQuestion1Test do
  use ExUnit.Case
  doctest Aoc.Question1

  test "part1/1 for test input" do
    assert Aoc.Question1.part1(:test) == 11
  end

  test "part2/1 for test input" do
    assert Aoc.Question1.part2(:test) == 31
  end

  test "counter/1" do
    assert Aoc.Question1.counter([1, 1, 2, 3]) == %{1 => 2, 2 => 1, 3 => 1}
  end
end
