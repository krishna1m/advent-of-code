defmodule Day4.Part2 do
  use GenServer

  @name SC

  ## client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: SC])
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  def process_single_line(line) do
    [card_number, numbers_lists] = line |> String.split(":")
    card_number = card_number |> String.split(~r"\s+") |> tl |> hd |> String.to_integer
    GenServer.call(@name, {:increment_for_card, {card_number, 1}})
    GenServer.call(@name, :reset_matches_count)
    [first_list, second_list] = numbers_lists |> String.split("|")
    first_list = first_list |> String.trim |> String.split(~r"\s+") |> Enum.map(&String.to_integer/1)
    second_list = second_list |> String.trim |> String.split(~r"\s+") |> Enum.map(&String.to_integer/1)
    first_list |> Enum.each(fn number ->
      case Enum.member?(second_list, number) do
        true ->
          GenServer.call(@name, :increment_match)
        false ->
          nil
      end
    end)
    matches_for_card = GenServer.call(@name, :get_matches_count)
    # IO.inspect "Number of matches found for card #{card_number}: #{matches_for_card}"
    value_for_card = GenServer.call(@name, {:value_for_card, card_number})
    cond do
      matches_for_card > 0 ->
        {map_value, _} = GenServer.call(@name, {:increment_for_following_cards, card_number + 1, card_number + matches_for_card, value_for_card})
        # IO.inspect("After processing card #{card_number}, map looks like below")
        # IO.inspect map_value
      true -> nil
    end
  end

  ## server callbacks
  def init(:ok) do
    {:ok, {%{}, 0}}    
  end

  def handle_call(:reset_matches_count, _from, state) do
    {map_value, _} = state
    {:reply, {map_value, 0}, {map_value, 0}}
  end

  def handle_call({:value_for_card, card_number}, _from, state) do
    {map_value, _} = state
    {:reply, Map.get(map_value, card_number, 0), state}
  end

  def handle_call(:increment_match, _from, state) do
    {map_value, matches} = state
    {:reply, {map_value, matches + 1}, {map_value, matches + 1}}
  end

  def handle_call(:get_matches_count, _from, state) do
    {_, matches} = state
    {:reply, matches, state}
  end

  def handle_call({:update_map, new_map}, _from, state) do
    {_, matches} = state
    {:reply, {new_map, matches}, {new_map, matches}}
  end

  def handle_call(:get_map, _from, state) do
    {map_value, _} = state
    {:reply, map_value, state}
  end

  def handle_call(:get_final_result, _from, state) do
    {map_value, _} = state
    # IO.inspect "Final map value below"
    # IO.inspect map_value
    final_result = map_value |> Map.values |> Enum.sum
    {:reply, final_result, state}
  end

  def handle_call({:increment_for_following_cards, start_card, end_card, value_for_card}, _from, state) do
    {old_map, matches} = state
    card_numbers = Enum.to_list(start_card..end_card)
    card_numbers |> Enum.each(fn card_no ->
      old_value = Map.get(old_map, card_no, 0)
      # IO.inspect "Old Value for card_no #{card_no}: #{old_value}"
    end)
    list_of_maps = card_numbers |> Enum.map(fn card_no ->
      old_value = Map.get(old_map, card_no, 0)
      %{card_no => (old_value + value_for_card)}
    end)
    # IO.inspect "list_of_maps below"
    # IO.inspect list_of_maps
    new_map = Enum.reduce(list_of_maps, old_map, fn map, acc -> Map.merge(acc, map) end)
    {:reply, {new_map, matches}, {new_map, matches}}
  end


  def handle_call({:increment_for_card, {card_number, by_value}}, _from, state) do
    {old_map, matches} = state
    new_map = old_map |> Map.update(card_number, by_value, fn value -> value + by_value end)
    {:reply, {new_map, matches}, {new_map, matches}}
  end

  def handle_cast(:stop, state) do
    IO.inspect "Stopping GenServer"
    {:stop, :normal, state}
  end

  def main do
    Day4.Part2.start_link()
    stream = File.stream!("resources/day4/input")
    stream |> Enum.each(fn line -> 
      line = line |> String.trim_trailing
      process_single_line(line)
    end)
    final_result = GenServer.call(@name, :get_final_result)
    IO.inspect final_result
    Day4.Part2.stop()
  end
end

