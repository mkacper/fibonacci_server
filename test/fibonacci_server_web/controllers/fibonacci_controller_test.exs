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

    test "returns 100 numbers at most by default", %{
      conn: conn
    } do
      # given
      number = 112

      # when
      conn = get(conn, ~p"/api/sequence?number=#{number}")

      # then
      assert resp = json_response(conn, 200)
      assert Enum.map(0..99, & &1) == Enum.map(resp, & &1["index"])
    end

    test "respects `page_number` and `page_size` query params", %{
      conn: conn
    } do
      # given
      number = 19
      page_size = 7
      expected_1st_page = Enum.slice(fibonacci_sequence_resp(number), 0..6)
      expected_2nd_page = Enum.slice(fibonacci_sequence_resp(number), 7..13)
      expected_3rd_page = Enum.slice(fibonacci_sequence_resp(number), 14..19)

      # when
      for {page_number, expected_result} <- [
            {1, expected_1st_page},
            {2, expected_2nd_page},
            {3, expected_3rd_page}
          ] do
        conn =
          get(
            conn,
            ~p"/api/sequence?number=#{number}&page_size=#{page_size}&page_number=#{page_number}"
          )

        # then
        assert resp = json_response(conn, 200)
        assert expected_result == resp
      end
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
