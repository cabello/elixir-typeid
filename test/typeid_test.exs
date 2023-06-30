defmodule TypeidTest do
  use ExUnit.Case
  doctest Typeid

  test "encode new UUID" do
    {:ok, result} = Typeid.encode("user")

    assert String.length(result) == 31
    assert String.starts_with?(result, "user_")
    {:ok, _} = CrockfordBase32.decode_to_integer(String.slice(result, 5..-1))
  end

  describe "valid spec" do
    test "nil" do
      assert Typeid.encode("", "00000000-0000-0000-0000-000000000000") ==
               {:ok, "00000000000000000000000000"}
    end

    test "one" do
      assert Typeid.encode("", "00000000-0000-0000-0000-000000000001") ===
               {:ok, "00000000000000000000000001"}
    end

    test "ten" do
      assert Typeid.encode("", "00000000-0000-0000-0000-00000000000a") ===
               {:ok, "0000000000000000000000000a"}
    end

    test "sixteen" do
      assert Typeid.encode("", "00000000-0000-0000-0000-000000000010") ===
               {:ok, "0000000000000000000000000g"}
    end

    test "thirty-two" do
      assert Typeid.encode("", "00000000-0000-0000-0000-000000000020") ===
               {:ok, "00000000000000000000000010"}
    end

    test "valid-alphabet" do
      assert Typeid.encode("prefix", "0110c853-1d09-52d8-d73e-1194e95b5f19") ===
               {:ok, "prefix_0123456789abcdefghjkmnpqrs"}
    end

    test "valid-uuidv7" do
      assert Typeid.encode("prefix", "01890a5d-ac96-774b-bcce-b302099a8057") ===
               {:ok, "prefix_01h455vb4pex5vsknk084sn02q"}
    end
  end

  describe "invalid spec" do
    test "prefix-uppercase" do
      assert Typeid.encode("PREFIX", "00000000-0000-0000-0000-000000000000") ===
               {:error, "The prefix should be lowercase with no uppercase letters"}
    end

    test "prefix-numeric" do
      assert Typeid.encode("12345", "00000000-0000-0000-0000-000000000000") ===
               {:error, "The prefix can't have numbers, it needs to be alphabetic"}
    end
  end
end
