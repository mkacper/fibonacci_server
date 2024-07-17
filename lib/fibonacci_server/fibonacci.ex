defmodule FibonacciServer.Fibonacci do
  @moduledoc """
  Main Fibonacci context module. Provides high-level API functions for handling
  all the application logic related to dealing with Fibonacci numbers.
  """
  alias FibonacciServer.Fibonacci.Blacklist
  alias FibonacciServer.Fibonacci.Numbers

  # API

  def value(n) do
    blacklist = Blacklist.get()

    if n in blacklist do
      {:error, :blacklisted}
    else
      {:ok, Numbers.value(n)}
    end
  end

  def sequence_with_blacklisted_backfilled(numbers_count, start_from \\ 0) do
    blacklist = Blacklist.get()
    blacklisted_count = blacklisted_count(blacklist, numbers_count, start_from)
    sequence(numbers_count + blacklisted_count, start_from, blacklist)
  end

  def sequence(n, start_from \\ 0) do
    blacklist = Blacklist.get()
    sequence(n, start_from, blacklist)
  end

  def blacklist(n), do: Blacklist.add(n)

  def allowlist(n), do: Blacklist.remove(n)

  # Helpers

  defp sequence(n, start_from, blacklist) do
    n
    |> Numbers.sequence(start_from)
    |> Enum.reject(&(&1.index in blacklist))
  end

  defp blacklisted_count(blacklisted_numbers, n, start_from) do
    blacklisted_numbers
    |> Enum.filter(&(&1 >= start_from && &1 <= n + 1))
    |> length()
  end
end
