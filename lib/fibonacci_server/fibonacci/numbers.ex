defmodule FibonacciServer.Fibonacci.Numbers do
  def value(0), do: 0
  def value(1), do: 1

  def value(n, opts \\ []) do
    {n0, n1} = value(n, _current_n = 1, {0, 1})

    if opts[:include_previous?] do
      {n0, n1}
    else
      n1
    end
  end

  defp value(n, n, {n0, n1}), do: {n0, n1}

  defp value(n, current_n, {n0, n1}) do
    value(n, current_n + 1, {n1, n0 + n1})
  end

  def sequence(n, _start_from = 0),
    do: do_sequence(n - 1, [%{index: 1, value: 1}, %{index: 0, value: 0}])

  def sequence(n, start_from) when is_integer(start_from) do
    {n0, n1} = value(start_from, include_previous?: true)

    [_n0 | seq] =
      do_sequence(n - start_from, [
        %{index: start_from, value: n1},
        %{index: start_from - 1, value: n0}
      ])

    seq
  end

  defp do_sequence(0, numbers), do: Enum.reverse(numbers)

  defp do_sequence(n, [%{index: n1_idx, value: n1} | [%{value: n0} | _]] = numbers) do
    do_sequence(n - 1, [%{index: n1_idx + 1, value: n0 + n1} | numbers])
  end
end
