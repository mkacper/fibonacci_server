defmodule FibonacciServerWeb.FibonacciController do
  alias FibonacciServer.Fibonacci
  use FibonacciServerWeb, :controller

  @default_page_size 100
  @default_cursor 0

  def sequence(conn, %{"number" => _number} = params) do
    case validate_params(params) do
      {:ok, params} ->
        current_number = number(params)
        sequence = sequence(params.number, current_number, params.cursor)

        json(conn, %{
          data: sequence,
          next_cursor: next_cursor(sequence, params.number, current_number)
        })

      {:error, reason} ->
        bad_request(conn, reason)
    end
  end

  def sequence(conn, _params) do
    bad_request(conn, "missing number parameter")
  end

  # Internals

  defp sequence(number, current_number, start_from) when number <= current_number do
    Fibonacci.sequence(number, start_from)
  end

  defp sequence(_number, current_number, start_from) do
    Fibonacci.sequence_with_blacklisted_backfilled(current_number, start_from)
  end

  defp validate_params(%{"number" => number} = params) do
    with {:ok, number} <- parse_number(number),
         {:ok, page_size} <- parse_page_size(params["page_size"]),
         {:ok, cursor} <- parse_cursor(params["cursor"]) do
      {:ok, %{number: number, page_size: page_size, cursor: cursor}}
    end
  end

  defp number(%{page_size: p_size, cursor: cursor, number: number}) do
    if number >= p_size do
      current_number = cursor + p_size - 1
      (current_number < number && current_number) || number
    else
      number
    end
  end

  defp next_cursor(sequence, number, current_number) when number > current_number do
    List.last(sequence).index + 1
  end

  defp next_cursor(_sequence, _number, _current_number), do: nil

  # Utils

  defp bad_request(conn, reason) do
    conn
    |> put_status(400)
    |> json(%{error: reason})
  end

  defp parse_number(number), do: parse_integer(number, "number must be an integer")

  defp parse_page_size(nil), do: {:ok, @default_page_size}
  defp parse_page_size(page_size), do: parse_integer(page_size, "page_size must be an integer")

  defp parse_cursor(nil), do: {:ok, @default_cursor}
  defp parse_cursor(cursor), do: parse_integer(cursor, "cursor must be an integer")

  defp parse_integer(int_str, error_reason) do
    case Integer.parse(int_str) do
      {int, ""} -> {:ok, int}
      _else -> {:error, error_reason}
    end
  end
end
