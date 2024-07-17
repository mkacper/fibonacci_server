defmodule FibonacciServer.FibonacciTest do
  use ExUnit.Case
  alias FibonacciServer.Fibonacci
  import FibonacciServer.Support.Numbers

  describe "value/1" do
    test "returns value for a given number" do
      # given
      number = 13
      sequence = fibonacci_sequence()
      {value, _} = Enum.at(sequence, 13)

      # when and then
      assert {:ok, value} == Fibonacci.value(number)
    end

    test "returns error if a given number is on the blacklist" do
      # given
      number = 13
      Fibonacci.blacklist(number)

      # cleanup
      on_exit(fn -> Fibonacci.allowlist(number) end)

      # when and then
      assert {:error, :blacklisted} == Fibonacci.value(number)
    end
  end

  describe "sequence/2" do
    test "returns sequence for a given number" do
      # given
      number = 13
      sequence = fibonacci_sequence()
      sequence = sequence |> Enum.take(number + 1) |> format_sequence()

      # when and then
      assert sequence == Fibonacci.sequence(number)
      assert Enum.slice(sequence, 5..number) == Fibonacci.sequence(number, 5)
    end

    test "drops blacklisted numbers from the sequence" do
      # given
      number = 13
      Fibonacci.blacklist(number)
      sequence = fibonacci_sequence()
      sequence = sequence |> Enum.take(number) |> format_sequence()

      # cleanup
      on_exit(fn -> Fibonacci.allowlist(number) end)

      # when and then
      assert sequence == Fibonacci.sequence(number)
    end
  end

  describe "sequence_with_blacklisted_backfilled/2" do
    test "returns sequence with backfilled blacklisted numbers" do
      # given
      number = 13
      blacklisted = [7, 11]
      for n <- blacklisted, do: Fibonacci.blacklist(n)
      sequence = fibonacci_sequence()

      sequence =
        sequence |> Enum.take(number + 3) |> format_sequence() |> reject_blacklisted(blacklisted)

      # cleanup
      on_exit(fn -> for n <- blacklisted, do: Fibonacci.allowlist(n) end)

      # when and then
      assert sequence == Fibonacci.sequence_with_blacklisted_backfilled(number)
    end
  end
end
