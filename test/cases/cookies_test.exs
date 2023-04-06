defmodule Distillery.Test.CookiesTest do
  use ExUnit.Case, async: true

  @tag numtests: 100
  test "generated cookies are always valid" do
    Enum.each(1..100, fn _ ->
      assert generated_cookie() |> is_valid_cookie()
    end)
  end

  test "can parse cookie via command line" do
    assert is_parsed_by_command_line(Distillery.Cookies.generate())
  end

  defp generated_cookie() do
    Distillery.Cookies.generate()
  end

  defp is_valid_cookie(x) when is_atom(x) do
    str = Atom.to_string(x)
    chars = String.to_charlist(str)

    with false <- String.contains?(str, ["-", "+", "'", "\"", "\\", "#", ","]),
         false <- Enum.any?(chars, fn b -> not (b >= ?! && b <= ?~) end),
         64 <- byte_size(str) do
      true
    else
      _ -> false
    end
  end

  defp is_valid_cookie(_x), do: false

  defp is_parsed_by_command_line(cookie) do
    cookie = Atom.to_string(cookie)

    case System.cmd("erl", ["-hidden", "-setcookie", cookie, "-noshell", "-s", "erlang", "halt"]) do
      {_, 0} -> true
      _ -> false
    end
  end
end
