defmodule FibonacciServerWeb.FibonacciController do
  alias FibonacciServer.Fibonacci
  use FibonacciServerWeb, :controller

  @default_page_size 100

  def sequence(conn, %{"number" => _} = params) do
    params = validate_params(params)
    sequence = Fibonacci.sequence(number(params), start_from(params))
    json(conn, sequence)
  end

  defp validate_params(%{"number" => number} = params) do
    %{
      "number" => String.to_integer(number),
      "page_size" =>
        (params["page_size"] && String.to_integer(params["page_size"])) || @default_page_size,
      "page_number" => (params["page_number"] && String.to_integer(params["page_number"])) || 1
    }
  end

  defp number(%{"page_size" => p_size, "page_number" => p_number, "number" => number}) do
    if number > p_size do
      current_number = p_size * p_number - 1
      (current_number < number && current_number) || number
    else
      number
    end
  end

  defp start_from(%{"page_size" => size, "page_number" => number}) do
    number * size - size
  end

  defp start_from(_), do: 0
end
