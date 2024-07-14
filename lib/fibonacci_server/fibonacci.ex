defmodule FibonacciServer.Fibonacci do
  alias FibonacciServer.Fibonacci.Blacklist
  alias FibonacciServer.Fibonacci.Numbers

  def number(n) do
    blacklist = Blacklist.get()
    number = Numbers.number(n)

    if number in blacklist do
      {:error, :blacklisted}
    else
      {:ok, number}
    end
  end

  def sequence(n, start_from \\ 0) do
    blacklist = Blacklist.get()

    n
    |> Numbers.sequence(start_from)
    |> Enum.reject(&(&1 in blacklist))
  end

  def blacklist(n), do: Blacklist.add(n)

  def allowlist(n), do: Blacklist.remove(n)
end
