defmodule Day1 do
  use GenServer

  @name TS
  @all_nums ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  @all_nums_reversed ["eno", "owt", "eerht", "ruof", "evif", "xis", "neves", "thgie", "enin"]

  ## client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: TS])
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  def current_value do
    GenServer.call(@name, :current_value)
  end

  def return_that_starts_with(input_string, list, acc \\ [])
  def return_that_starts_with(_input_string, [], acc), do: acc
  def return_that_starts_with(input_string, [head | tail], acc) do
    cond do
      head == input_string ->
        [head]
      String.starts_with?(head, input_string) ->
        return_that_starts_with(input_string, tail, [head | acc])
      true ->
        return_that_starts_with(input_string, tail, acc)
    end
  end


  def give_first_digit(rem_string, list_numbers, buffer \\ "") do
    # IO.inspect("rem_string: #{rem_string}, buffer: #{buffer}")
    case rem_string do
      "" ->
        nil
      <<head::utf8>> <> rest ->
        cond do
          head >= 97 and head <= 122 ->
            result_list = return_that_starts_with(buffer <> <<head>>, list_numbers)
            cond do
              length(result_list) == 0 ->
                cond do
                  buffer == "" ->
                    give_first_digit(rest, list_numbers)
                  true ->
                    all_but_first = buffer |> String.to_charlist |> tl |> List.to_string
                    give_first_digit(all_but_first <> rem_string, list_numbers)
                end
              length(result_list) == 1 ->
                buffer = buffer <> <<head>>
                singular_match = result_list |> hd
                cond do
                  buffer == singular_match ->
                    the_number = singular_match |> get_corresponding_num
                    # IO.inspect("Found number: #{the_number}, rest: #{rest}, buffer: #{buffer}, singular_match: #{singular_match}")
                    the_number
                  true ->
                    give_first_digit(rest, list_numbers, buffer)
                end
              true ->
                give_first_digit(rest, list_numbers, buffer <> <<head>>)
            end
          head >= 48 and head <= 57 ->
            <<head>> |> String.to_integer
          true ->
            nil
        end
    end
  end

  def get_corresponding_num(number_string) do
    string_num = %{one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9, eno: 1, owt: 2, eerht: 3, ruof: 4, evif: 5, xis: 6, neves: 7, thgie: 8, enin: 9} 
    atom = number_string |> String.to_atom
    string_num[atom]
  end

  def process_single_line(line) do
    first_num = give_first_digit(line, @all_nums)
    last_num = give_first_digit(line |> String.reverse, @all_nums_reversed)
    first_num * 10 + last_num
  end

  def update(line_result) do
    GenServer.call(@name, {:update, line_result})
  end

  ## server callbacks
  def init(:ok) do
    {:ok, 0}    
  end

  def handle_call(:current_value, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update, line_result}, _from, state) do
    {:reply, state + line_result, state + line_result}
  end

  def handle_cast(:stop, state) do
    IO.inspect "Stopping GenServer"
    {:stop, :normal, state}
  end

  def main do
    Day1.start_link()
    stream = File.stream!("resources/day1/input")
    stream |> Enum.each(fn line -> 
      line = line |> String.trim_trailing
      line_result = process_single_line(line)
      Day1.update(line_result)
      # IO.inspect("#{line},#{line_result}")
    end)
    IO.inspect Day1.current_value()
    Day1.stop()
  end
end
