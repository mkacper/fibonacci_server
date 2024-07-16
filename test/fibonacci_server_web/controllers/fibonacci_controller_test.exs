defmodule FibonacciServerWeb.FibonacciControllerTest do
  alias FibonacciServer.Fibonacci
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
      assert json_response(conn, 200)["data"] == expected_seq
    end

    test "returns 100 numbers at most by default", %{
      conn: conn
    } do
      # given
      number = 112

      # when
      conn = get(conn, ~p"/api/sequence?number=#{number}")

      # then
      assert resp = json_response(conn, 200)
      assert Enum.map(0..99, & &1) == Enum.map(resp["data"], & &1["index"])
    end

    test "respects `page_number` and `cursor` query params", %{
      conn: conn
    } do
      # given
      number = 19
      page_size = 7
      expected_1st_page = fibonacci_sequence_resp(number, 0..6)
      expected_2nd_page = fibonacci_sequence_resp(number, 7..13)
      expected_3rd_page = fibonacci_sequence_resp(number, 14..19)

      # when
      for expected_result <- [expected_1st_page, expected_2nd_page, expected_3rd_page],
          reduce: 0 do
        cursor ->
          conn =
            get(
              conn,
              ~p"/api/sequence?number=#{number}&page_size=#{page_size}&cursor=#{cursor}"
            )

          # then
          assert result = json_response(conn, 200)
          assert expected_result == result["data"]
          assert result["next_cursor"]
          result["next_cursor"]
      end
    end

    test "does not list blacklisted numbers", %{
      conn: conn
    } do
      # given
      number = 10
      blacklisted = [3, 7]

      expected_result =
        number |> fibonacci_sequence_resp() |> reject_blacklisted(blacklisted)

      # when
      for n <- blacklisted, do: Fibonacci.blacklist(n)
      conn = get(conn, ~p"/api/sequence?number=#{number}")

      # then
      assert expected_result == json_response(conn, 200)["data"]

      # cleanup
      for n <- blacklisted, do: Fibonacci.allowlist(n)
    end

    test "backfill blacklisted numbers if more than one page", %{
      conn: conn
    } do
      # given
      number = 13
      page_size = 5
      blacklisted = [3, 7, 11]

      expected_1st_page =
        number
        |> fibonacci_sequence_resp(0..5)
        |> reject_blacklisted(blacklisted)

      expected_2nd_page =
        number
        |> fibonacci_sequence_resp(6..12)
        |> reject_blacklisted(blacklisted)

      expected_3rd_page = fibonacci_sequence_resp(number, 13..13)

      # when
      for n <- blacklisted, do: Fibonacci.blacklist(n)

      for expected_result <- [expected_1st_page, expected_2nd_page, expected_3rd_page],
          reduce: 0 do
        cursor ->
          conn =
            get(
              conn,
              ~p"/api/sequence?number=#{number}&page_size=#{page_size}&cursor=#{cursor}"
            )

          # then
          assert result = json_response(conn, 200)
          assert expected_result == result["data"]
          result["next_cursor"]
      end

      # cleanup
      for n <- blacklisted, do: Fibonacci.allowlist(n)
    end
  end

  # Helpers

  defp fibonacci_sequence_resp(number), do: fibonacci_sequence_resp(number, 0..number)

  defp fibonacci_sequence_resp(number, range) do
    seq = fibonacci_sequence()

    seq
    |> Enum.take(number + 1)
    |> Enum.slice(range)
    |> Enum.map(&%{index: elem(&1, 1), value: elem(&1, 0)})
    |> Jason.encode!()
    |> Jason.decode!()
  end

  defp reject_blacklisted(sequence, blacklist),
    do: Enum.reject(sequence, &(&1["index"] in blacklist))

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
