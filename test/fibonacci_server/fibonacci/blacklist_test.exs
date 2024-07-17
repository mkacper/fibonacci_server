defmodule FibonacciServer.Fibonacci.BlacklistTest do
  use ExUnit.Case
  alias FibonacciServer.Fibonacci.Blacklist

  setup do
    on_exit(fn -> Agent.update(Blacklist, fn _ -> [] end) end)
  end

  test "add/1 adds the number to the blacklist" do
    assert :ok = Blacklist.add(1234)
    assert :ok = Blacklist.add(567)
    assert [567, 1234] = Blacklist.get()
  end

  test "add/1 ignores dupliacates" do
    assert :ok = Blacklist.add(1234)
    assert :ok = Blacklist.add(1234)
    assert [1234] = Blacklist.get()
  end

  test "remove/1 removes a number from the blacklist" do
    assert :ok = Blacklist.add(1234)
    assert :ok = Blacklist.remove(1234)
    assert [] = Blacklist.get()
  end

  test "remove/1 handles a number that is not on the blacklist" do
    assert :ok = Blacklist.remove(1234)
    assert [] = Blacklist.get()
  end
end
