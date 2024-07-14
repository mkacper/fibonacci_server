defmodule FibonacciServer.Sequence do
  def number(0), do: 0
  def number(1), do: 1
  def number(n), do: number(n, _current_n = 1, {0, 1})

  defp number(n, n, {_n0, n1}), do: n1

  defp number(n, current_n, {n0, n1}) do
    number(n, current_n + 1, {n1, n0 + n1})
  end

  def numbers(n), do: numbers(n - 1, [1, 0])

  defp numbers(0, numbers), do: Enum.reverse(numbers)

  defp numbers(n, [n0 | [n1 | _]] = numbers) do
    numbers(n - 1, [n0 + n1 | numbers])
  end
end
