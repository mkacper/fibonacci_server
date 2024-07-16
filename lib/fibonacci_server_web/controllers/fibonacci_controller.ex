defmodule FibonacciServerWeb.FibonacciController do
  alias FibonacciServer.Fibonacci
  use FibonacciServerWeb, :controller

  @default_page_size 100

  def sequence(conn, %{"number" => _number} = params) do
    params = validate_params(params)
    current_number = number(params)
    sequence = sequence(params["number"], current_number, params["cursor"])
    cursor = List.last(sequence).index + 1
    json(conn, %{data: sequence, next_cursor: cursor})
  end

  # Internals

  defp sequence(number, current_number, start_from) when number <= current_number do
    Fibonacci.sequence(number, start_from)
  end

  defp sequence(_number, current_number, start_from) do
    Fibonacci.sequence_with_blacklisted_backfilled(current_number, start_from)
  end

  defp validate_params(%{"number" => number} = params) do
    %{
      "number" => String.to_integer(number),
      "page_size" =>
        (params["page_size"] && String.to_integer(params["page_size"])) || @default_page_size,
      "cursor" => (params["cursor"] && String.to_integer(params["cursor"])) || 0
    }
  end

  defp number(%{"page_size" => p_size, "cursor" => cursor, "number" => number}) do
    if number > p_size do
      current_number = cursor + p_size - 1
      (current_number < number && current_number) || number
    else
      number
    end
  end
end
