defmodule Day4.Part1 do
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
    numbers_lists = line |> String.split(":") |> tl |> hd
    [first_list, second_list] = numbers_lists |> String.split("|")
    first_list = first_list |> String.trim |> String.split(~r"\s+") |> Enum.map(&String.to_integer/1)
    second_list = second_list |> String.trim |> String.split(~r"\s+") |> Enum.map(&String.to_integer/1)
    first_list |> Enum.each(fn number ->
      case Enum.member?(second_list, number) do
        true ->
          {_, curr_val} = GenServer.call(@name, :current_value)
          cond do
            curr_val == 0 ->
              GenServer.call(@name, {:increment_sum, 1})
              GenServer.call(@name, {:set_curr_val, 1})
            curr_val == 1 ->
              GenServer.call(@name, {:increment_sum, 1})
              GenServer.call(@name, {:set_curr_val, 2})
            true ->
              GenServer.call(@name, {:increment_sum, curr_val})
              GenServer.call(@name, {:set_curr_val, 2 * curr_val})
          end
        false ->
          nil
      end
    end)
    GenServer.call(@name, :reset_curr_val)
  end

  ## server callbacks
  def init(:ok) do
    {:ok, {0, 0}}    
  end

  def handle_call(:current_value, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:increment_sum, line_sum}, _from, state) do
    {total_sum, curr_val} = state
    {:reply, {total_sum + line_sum, curr_val}, {total_sum + line_sum, curr_val}}
  end

  def handle_call({:set_curr_val, curr_val}, _from, state) do
    {total_sum, _} = state
    {:reply, {total_sum, curr_val}, {total_sum, curr_val}}
  end

  def handle_call(:reset_curr_val, _from, state) do
    {total_sum, _} = state
    {:reply, {total_sum, 0}, {total_sum, 0}}
  end

  def handle_cast(:stop, state) do
    IO.inspect "Stopping GenServer"
    {:stop, :normal, state}
  end

  def main do
    Day4.Part1.start_link()
    stream = File.stream!("resources/day4/input")
    stream |> Enum.each(fn line -> 
      line = line |> String.trim_trailing
      process_single_line(line)
    end)
    {final_result, _}= GenServer.call(@name, :current_value)
    IO.inspect final_result
    Day4.Part1.stop()
  end
end

