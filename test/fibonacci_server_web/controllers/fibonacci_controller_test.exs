defmodule FibonacciServerWeb.FibonacciControllerTest do
  alias FibonacciServer.Fibonacci
  use FibonacciServerWeb.ConnCase

  import FibonacciServer.Support.Numbers

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
      assert resp = json_response(conn, 200)
      assert resp["data"] == expected_seq
      refute resp["next_cursor"]
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
      assert resp["next_cursor"]
    end

    test "returns correct number of results when number equals page_size", %{
      conn: conn
    } do
      # given
      number = 112

      # when
      conn = get(conn, ~p"/api/sequence?number=#{number}&page_size=#{number}")

      # then
      assert number == conn |> json_response(200) |> Map.get("data") |> length()
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
          result["next_cursor"]
      end
    end

    test "does not list blacklisted numbers", %{
      conn: conn
    } do
      # given
      number = 10
      blacklisted = [3, 7]

      # cleanup
      on_exit(fn -> for n <- blacklisted, do: Fibonacci.allowlist(n) end)

      expected_result =
        number |> fibonacci_sequence_resp() |> reject_blacklisted(blacklisted)

      # when
      for n <- blacklisted, do: Fibonacci.blacklist(n)
      conn = get(conn, ~p"/api/sequence?number=#{number}")

      # then
      assert expected_result == json_response(conn, 200)["data"]
    end

    test "backfill blacklisted numbers if more than one page", %{
      conn: conn
    } do
      # given
      number = 13
      page_size = 5
      blacklisted = [3, 7, 11]

      # cleanup
      on_exit(fn -> for n <- blacklisted, do: Fibonacci.allowlist(n) end)

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
    end

    test "returns bad request if number param is missing", %{conn: conn} do
      assert %{"error" => "missing number parameter"} =
               conn |> get(~p"/api/sequence") |> json_response(400)
    end

    test "returns bad request if number param cannot be parsed to string", %{conn: conn} do
      assert %{"error" => "number must be a non-negative integer"} =
               conn |> get(~p"/api/sequence?number=not_a_string") |> json_response(400)
    end

    test "returns bad request if page_size param cannot be parsed to string", %{conn: conn} do
      assert %{"error" => "page_size must be a positive integer"} =
               conn
               |> get(~p"/api/sequence?number=10&page_size=not_a_string")
               |> json_response(400)
    end

    test "returns bad request if cursor param cannot be parsed to string", %{conn: conn} do
      assert %{"error" => "cursor must be a non-negative integer"} =
               conn
               |> get(~p"/api/sequence?number=10&cursor=not_a_string")
               |> json_response(400)
    end

    test "returns bad request if number is not a non-negative integer", %{conn: conn} do
      assert %{"error" => "number must be a non-negative integer"} =
               conn |> get(~p"/api/sequence?number=-1") |> json_response(400)
    end

    test "returns error if page_size is not a positive integer", %{conn: conn} do
      assert %{"error" => "page_size must be a positive integer"} =
               conn
               |> get(~p"/api/sequence?number=10&page_size=-1")
               |> json_response(400)
    end

    test "returns error if cursor is not a positive integer", %{conn: conn} do
      assert %{"error" => "cursor must be a non-negative integer"} =
               conn
               |> get(~p"/api/sequence?number=10&cursor=-1")
               |> json_response(400)
    end

    test "returns error if cursor is greater than number", %{conn: conn} do
      assert %{"error" => "cursor is invalid"} =
               conn
               |> get(~p"/api/sequence?number=10&cursor=11")
               |> json_response(400)
    end
  end

  describe "GET /api/value" do
    test "returns value for a given number", %{
      conn: conn
    } do
      # given
      number = 12
      sequence = fibonacci_sequence()
      {expected_value, _} = Enum.at(sequence, 12)

      # when
      conn = get(conn, ~p"/api/value/#{number}")

      # then
      assert expected_value == json_response(conn, 200)["data"]
    end

    test "returns not found error if a given number is blacklisted", %{
      conn: conn
    } do
      # given
      number = 12
      Fibonacci.blacklist(number)

      # cleanup
      on_exit(fn -> Fibonacci.allowlist(number) end)

      # when
      conn = get(conn, ~p"/api/value/#{number}")

      # then
      assert %{"error" => "number not found"} == json_response(conn, 404)
    end

    test "returns bad request error if a given number is not a positive integer", %{
      conn: conn
    } do
      for number <- ["not_an_int", "-1"] do
        assert %{"error" => "number must be a non-negative integer"} =
                 conn
                 |> get(~p"/api/value/#{number}")
                 |> json_response(400)
      end
    end
  end

  describe "POST /api/blacklist/numbers" do
    test "adds a number to a blacklist", %{
      conn: conn
    } do
      # given
      number = 12

      # cleanup
      on_exit(fn -> Fibonacci.allowlist(number) end)

      # when
      conn = post(conn, ~p"/api/blacklist/numbers", %{"number" => "#{number}"})

      # then
      assert %{"result" => "ok"} == json_response(conn, 201)
      assert [^number] = Fibonacci.Blacklist.get()
    end

    test "returns bad request error if a given number is not a positive integer", %{
      conn: conn
    } do
      for number <- ["not_an_int", "-1"] do
        assert %{"error" => "number must be a non-negative integer"} =
                 conn
                 |> post(~p"/api/blacklist/numbers", %{"number" => "#{number}"})
                 |> json_response(400)
      end
    end
  end

  describe "DELETE /api/blacklist/numbers/:number" do
    test "adds a number to a blacklist", %{
      conn: conn
    } do
      # given
      number = 12
      Fibonacci.blacklist(number)

      # cleanup
      on_exit(fn -> Fibonacci.allowlist(number) end)

      # when
      conn = delete(conn, ~p"/api/blacklist/numbers/#{number}")

      # then
      assert %{"result" => "ok"} == json_response(conn, 200)
      assert [] = Fibonacci.Blacklist.get()
    end

    test "returns bad request error if a given number is not a positive integer", %{
      conn: conn
    } do
      for number <- ["not_an_int", "-1"] do
        assert %{"error" => "number must be a non-negative integer"} =
                 conn
                 |> delete(~p"/api/blacklist/numbers/#{number}")
                 |> json_response(400)
      end
    end
  end

  # Helpers

  defp fibonacci_sequence_resp(number), do: fibonacci_sequence_resp(number, 0..number)

  defp fibonacci_sequence_resp(number, range) do
    seq = fibonacci_sequence()

    seq
    |> Enum.take(number + 1)
    |> Enum.slice(range)
    |> format_sequence()
    |> Jason.encode!()
    |> Jason.decode!()
  end
end
