defmodule Aoc.Input do
  def testin do
    File.read!("test.input")
  end

  def realin do
    File.read!("real.input")
  end
end
