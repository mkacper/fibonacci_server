defmodule FibonacciServer.Fibonacci.Blacklist do
  @moduledoc """
  In-memory storage for the blacklisted numbers.
  """
  use Agent

  # API

  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def add(number) when is_integer(number) do
    Agent.update(__MODULE__, &add_to_list(&1, number))
  end

  def remove(number) when is_integer(number) do
    Agent.update(__MODULE__, &remove_from_list(&1, number))
  end

  # Helpers

  # AUTHOR COMMENT: we may consider different data type for storing the numbers
  defp add_to_list(list, number), do: Enum.uniq([number | list])
  defp remove_from_list(list, number), do: List.delete(list, number)
end
