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

  def value(conn, %{"number" => number}) do
    with {:ok, number} <- parse_number(number),
         {:ok, value} <- Fibonacci.value(number) do
      json(conn, %{data: value})
    else
      {:error, :blacklisted} -> not_found(conn)
      {:error, reason} -> bad_request(conn, reason)
    end
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
         {:ok, cursor} <- parse_cursor(params["cursor"], number) do
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

  defp not_found(conn) do
    conn
    |> put_status(404)
    |> json(%{error: "number not found"})
  end

  defp parse_number(number),
    do: parse_non_neg_integer(number, "number must be a non-negative integer")

  defp parse_page_size(nil), do: {:ok, @default_page_size}

  defp parse_page_size(page_size),
    do: parse_pos_integer(page_size, "page_size must be a positive integer")

  defp parse_cursor(nil, _number), do: {:ok, @default_cursor}

  defp parse_cursor(cursor, number) do
    case parse_non_neg_integer(cursor, "cursor must be a non-negative integer") do
      {:ok, cursor} when cursor > number -> {:error, "cursor is invalid"}
      other -> other
    end
  end

  defp parse_non_neg_integer(int_str, error_reason) do
    case parse_integer(int_str) do
      {:ok, int} when int >= 0 -> {:ok, int}
      _else -> {:error, error_reason}
    end
  end

  defp parse_pos_integer(int_str, error_reason) do
    case parse_integer(int_str) do
      {:ok, int} when int > 0 -> {:ok, int}
      _else -> {:error, error_reason}
    end
  end

  defp parse_integer(int_str) do
    case Integer.parse(int_str) do
      {int, ""} -> {:ok, int}
      _else -> :error
    end
  end
end
