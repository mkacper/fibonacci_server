defmodule FibonacciServer.Support.Numbers do
  def fibonacci_sequence() do
    Enum.with_index([
      0,
      1,
      1,
      2,
      3,
      5,
      8,
      13,
      21,
      34,
      55,
      89,
      144,
      233,
      377,
      610,
      987,
      1597,
      2584,
      4181
    ])
  end

  def format_sequence(sequence),
    do: Enum.map(sequence, &%{index: elem(&1, 1), value: elem(&1, 0)})
end
