defmodule Day2 do
  use GenServer

  @name CC

  ## client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: CC])
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  def current_value do
    GenServer.call(@name, :current_value)
  end

  def power_set(sets) do
    {red, green, blue} = 
      sets |> Enum.map(&rgb_count/1) |> List.flatten |> List.foldl({0, 0, 0}, fn {color, count}, {r, g, b} ->
        case color do
          "red" ->
            {max(r, count), g, b}
          "green" ->
            {r, max(g, count), b}
          "blue" ->
            {r, g, max(count, b)}
          _ ->
            nil
        end
      end)
    red * green * blue
  end

  def rgb_count(set) do
    set |> String.trim |> String.split(",")
    |> Enum.map(fn count_color ->
      [count, color] = count_color |> String.trim |> String.split(" ")
      {color, count |> String.to_integer}
    end)
  end

  def check_if_more(current_count, max_count) do 
    cond do
      current_count > max_count ->
        1
      true ->
        0
    end
  end

  def is_valid_set(set, red_count, green_count, blue_count) do
    list_of_color_counts = set |> rgb_count
    to_check_if_all_colors_good = 
      list_of_color_counts |> Enum.map(fn {color, count} ->
        case color do
          "red" ->
            check_if_more(count, red_count)
          "green" ->
            check_if_more(count, green_count)
          "blue" ->
            check_if_more(count, blue_count)
          _ -> 
            nil
        end
      end)
    cond do
      Enum.sum(to_check_if_all_colors_good) == 0 ->
        true
      true ->
        false
    end
  end

  def process_single_line(line, red_count, green_count, blue_count) do
    [game_number_text, sets] = line |> String.split(":")
    [_, game_number] = game_number_text |> String.split(" ")
    game_number = game_number |> String.to_integer
    sets = sets |> String.split(";") |> Enum.map(&String.trim/1)
    is_game_good = sets
                   |> Enum.map(fn set -> is_valid_set(set, red_count, green_count, blue_count) end)
                   |> Enum.all?(fn x -> x end)
    is_game_good = 
      cond do
        is_game_good ->
          game_number
        true ->
          0
      end
    {is_game_good, power_set(sets)}
  end

  def update(is_game_valid, game_power_set) do
    GenServer.call(@name, {:update, {is_game_valid, game_power_set}})
  end

  ## server callbacks
  def init(:ok) do
    {:ok, {0, 0}}    
  end

  def handle_call(:current_value, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update, {is_game_valid, game_power_set}}, _from, state) do
    {id_sum, total_power_set} = state
    new_state = {id_sum + is_game_valid, total_power_set + game_power_set}
    {:reply, new_state, new_state}
  end

  def handle_cast(:stop, state) do
    IO.inspect "Stopping GenServer"
    {:stop, :normal, state}
  end

  def main do
    Day2.start_link()
    stream = File.stream!("input")
    red_count = 12
    green_count = 13
    blue_count = 14
    stream |> Enum.each(fn line -> 
      line = line |> String.trim_trailing
      {game_valid, game_power_set} = process_single_line(line, red_count, green_count, blue_count)
      Day2.update(game_valid, game_power_set)
    end)
    {id_sum_total, total_power_set} = Day2.current_value()
    IO.inspect "solution 1: #{id_sum_total}"
    IO.inspect "solution 2: #{total_power_set}"
    Day2.stop()
  end
end
