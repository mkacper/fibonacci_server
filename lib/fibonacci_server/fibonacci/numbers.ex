defmodule FibonacciServer.Fibonacci.Numbers do
  def number(0), do: 0
  def number(1), do: 1

  def number(n, opts \\ []) do
    {n0, n1} = number(n, _current_n = 1, {0, 1})

    if opts[:include_previous?] do
      {n0, n1}
    else
      n1
    end
  end

  defp number(n, n, {n0, n1}), do: {n0, n1}

  defp number(n, current_n, {n0, n1}) do
    number(n, current_n + 1, {n1, n0 + n1})
  end

  def sequence(n, _start_from = 0), do: do_sequence(n - 1, [1, 0])

  def sequence(n, start_from) when is_integer(start_from) do
    {n0, n1} = number(start_from, include_previous?: true)
    [_n0 | [_n1 | seq]] = do_sequence(n - start_from, [n1, n0])
    seq
  end

  defp do_sequence(0, numbers), do: Enum.reverse(numbers)

  defp do_sequence(n, [n0 | [n1 | _]] = numbers) do
    do_sequence(n - 1, [n0 + n1 | numbers])
  end
end
