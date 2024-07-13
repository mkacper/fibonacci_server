defmodule FibonacciServer.Sequence do
  def number(0), do: 0
  def number(1), do: 1

  def number(n), do: number(n, _current_n = 0, {0, 1})
  def number(n, n, {n0, _n1}), do: n0

  def number(n, current_n, {n0, n1}) do
    number(n, current_n + 1, {n1, n0 + n1})
  end
end
