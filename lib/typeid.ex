defmodule Typeid do
  defstruct prefix: nil, suffix: nil, uuid: nil

  @moduledoc ~S"""
  Documentation for `Typeid`.
  """

  @doc ~S"""
  Parse a type ID into prefix and suffix.

  ## Examples

      iex> Typeid.decode("user_01h2e8kqvbfwea724h75qc655w")
      {:ok, %Typeid{
        prefix: "user",
        suffix: "01h2e8kqvbfwea724h75qc655w",
        uuid: "00622722-77da-dfc7-28e2-244e5bb0c52f"}}

      iex> Typeid.decode("user_01h2e8kqvbfwea724h75qc655o")
      {:error, "Invalid base 32 encoded ID"}
  """
  def decode(typeid) do
    {prefix, suffix} = typeid |> String.split("_") |> List.to_tuple()

    case CrockfordBase32.decode_to_binary(suffix) do
      {:ok, binary_uuid} ->
        {:ok,
         %Typeid{
           prefix: prefix,
           suffix: suffix,
           uuid: binary_uuid |> Uniq.UUID.to_string()
         }}

      {:error, _} ->
        {:error, "Invalid base 32 encoded ID"}
    end
  end

  @doc ~S"""
  Encode a type ID from a type and UUID.

  ## Examples

      iex> Typeid.encode("user", "01889c89-df6b-7f1c-a388-91396ec314bc")
      {:ok, "user_01h2e8kqvbfwea724h75qc655w"}

      iex> Typeid.encode("user", "0649s2ezddzhs8w8j4wpxgrmqg")
      {:ok, "user_0649s2ezddzhs8w8j4wpxgrmqg"}

      iex> Typeid.encode("User", "0649s2ezddzhs8w8j4wpxgrmqg")
      {:error, "Invalid type. Must be lowercase ascii letters [0-9a-z]*"}

      iex> Typeid.encode("User", "0649s2ezddzhs8w8j4wpxgrmqg")
      {:error, "Invalid type. Must be lowercase ascii letters [0-9a-z]*"}

      iex> Typeid.encode("user", "invalid")
      {:error, "Invalid length. ID should have 26 characters, got 7"}
  """
  def encode(typeid = %Typeid{}) do
    encode(typeid.prefix, typeid.uuid)
  end

  def encode(type) do
    encode(type, Uniq.UUID.uuid7())
  end

  def encode(type, base32id) when byte_size(base32id) == 26 do
    cond do
      String.downcase(type) != type ->
        {:error, "Invalid type. Must be lowercase ascii letters [0-9a-z]*"}

      true ->
        {:ok, join(type, base32id)}
    end
  end

  def encode(type, uuid) when byte_size(uuid) == 36 do
    cond do
      String.downcase(type) != type ->
        {:error, "Invalid type. Must be lowercase ascii letters [0-9a-f]*"}

      true ->
        eid =
          uuid
          |> Uniq.UUID.to_string(:hex)
          |> String.to_integer(16)
          |> CrockfordBase32.encode()
          |> String.downcase()
          |> String.pad_leading(26, "0")

        {:ok, join(type, eid)}
    end
  end

  def encode(_, id) do
    {:error, "Invalid length. ID should have 26 characters, got #{String.length(id)}"}
  end

  defp join(prefix, suffix) do
    if prefix == "" do
      suffix
    else
      prefix <> "_" <> suffix
    end
  end
end
