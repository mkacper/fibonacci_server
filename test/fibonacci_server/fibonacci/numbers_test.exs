defmodule FibonacciServer.Fibonacci.NumbersTest do
  use ExUnit.Case
  alias FibonacciServer.Fibonacci.Numbers

  import FibonacciServer.Support.Numbers

  describe "value/1" do
    test "returns correct value given indexes" do
      for {value, index} <- fibonacci_sequence(), do: assert(value == Numbers.value(index))
    end
  end

  describe "sequence/2" do
    test "returns correct sequence for given indexes" do
      sequence = fibonacci_sequence()

      for {_value, index} <- sequence do
        expected_sequence = sequence |> Enum.take(index + 1) |> format_sequence()

        assert expected_sequence == Numbers.sequence(index, 0)
      end
    end

    test "returns correct sequence for given indexes respecting `start_from`" do
      sequence = fibonacci_sequence()
      {_value, number} = List.last(sequence)

      for {_value, start_from} <- sequence do
        expected_sequence =
          sequence
          |> Enum.slice(start_from..number)
          |> format_sequence()

        assert expected_sequence == Numbers.sequence(number, start_from)
      end
    end
  end
end
