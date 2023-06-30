defmodule TypeidTest do
  use ExUnit.Case
  doctest Typeid

  test "encode new UUID" do
    {:ok, result} = Typeid.encode("user")

    assert String.length(result) == 31
    assert String.starts_with?(result, "user_")
    {:ok, _} = CrockfordBase32.decode_to_binary(String.slice(result, 5..-1))
  end

  describe "spec" do
    test "nil" do
      t = %Typeid{
        prefix: "",
        uuid: "00000000-0000-0000-0000-000000000000"
      }

      assert Typeid.encode(t) == {:ok, "00000000000000000000000000"}
    end

    test "one" do
      t = %Typeid{
        prefix: "",
        uuid: "00000000-0000-0000-0000-000000000001"
      }

      assert Typeid.encode(t) == {:ok, "0000000000000000000000000a"}
    end

    test "ten" do
      t = %Typeid{
        prefix: "",
        uuid: "00000000-0000-0000-0000-00000000000a"
      }

      assert Typeid.encode(t) == {:ok, "0000000000000000000000000a"}
    end

    test "sixteen" do
      t = %Typeid{
        prefix: "",
        uuid: "00000000-0000-0000-0000-000000000010"
      }

      assert Typeid.encode(t) == {:ok, "0000000000000000000000000g"}
    end

    test "thirty-two" do
      t = %Typeid{
        prefix: "",
        uuid: "00000000-0000-0000-0000-000000000020"
      }

      assert Typeid.encode(t) == {:ok, "00000000000000000000000010"}
    end

    test "valid-alphabet" do
      t = %Typeid{
        prefix: "prefix",
        uuid: "0110c853-1d09-52d8-d73e-1194e95b5f19"
      }

      assert Typeid.encode(t) == {:ok, "prefix_0123456789abcdefghjkmnpqrs"}
    end

    test "valid-uuidv7" do
      t = %Typeid{
        prefix: "prefix",
        uuid: "01890a5d-ac96-774b-bcce-b302099a8057"
      }

      assert Typeid.encode(t) == {:ok, "prefix_01h455vb4pex5vsknk084sn02q"}
    end
  end
end
