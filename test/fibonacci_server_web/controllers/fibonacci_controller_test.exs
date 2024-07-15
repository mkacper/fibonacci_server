defmodule FibonacciServerWeb.FibonacciControllerTest do
  use FibonacciServerWeb.ConnCase

  describe "GET /api/sequence" do
    test "returns sequence of numbers with corresponding values for a single page result", %{
      conn: conn
    } do
      # given
      number = 12
      expected_seq = fibonacci_sequence_resp(number)

      # when
      conn = get(conn, ~p"/api/sequence?number=#{number}")

      # then
      assert json_response(conn, 200) == expected_seq
    end
  end

  # Helpers

  defp fibonacci_sequence_resp(number),
    do:
      fibonacci_sequence()
      |> Enum.take(number + 1)
      |> Enum.map(&%{index: elem(&1, 1), value: elem(&1, 0)})
      |> Jason.encode!()
      |> Jason.decode!()

  defp fibonacci_sequence() do
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
end
