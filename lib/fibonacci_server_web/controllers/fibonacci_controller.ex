defmodule FibonacciServerWeb.FibonacciController do
  alias FibonacciServer.Fibonacci
  use FibonacciServerWeb, :controller

  def sequence(conn, %{"number" => number} = params) do
    params = validate_params(params)
    sequence = Fibonacci.sequence(params["number"])
    json(conn, sequence)
  end

  defp validate_params(%{"number" => number}) do
    %{"number" => String.to_integer(number)}
  end
end
