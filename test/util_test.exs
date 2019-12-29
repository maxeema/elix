defmodule Util.Test do
  use ExUnit.Case

  describe "-urls-" do
    test "ensure http by default" do
      assert Util.parse_url("t.me").scheme == "http"
    end
    test "ensure host" do
      assert Util.parse_url("t.me").host == "t.me"
      assert Util.parse_url("https://fb.com/dfhjaf?fhja1=1&j1#dha,dfg").host == "fb.com"
    end
    test "url host" do
      assert Util.url_host("fb.com") == "fb.com"
      assert Util.url_host("https://fb.com") == "fb.com"
      assert Util.url_host(" ") == nil
      assert Util.url_host(nil) == nil
    end
    test "check on empty / nil" do
      assert Util.parse_url(" ").host == nil
      assert Util.parse_url("").host == nil
      assert Util.parse_url(nil).host == nil
    end
  end

  describe "-strings-" do
    test "validate is_not_empty" do
      assert Util.is_not_empty("abc")
      assert Util.is_not_empty("1")
      assert Util.is_not_empty(nil) == false
      assert Util.is_not_empty(" ") == false
      assert Util.is_not_empty("") == false
    end

    test "validate is_nil_or_empty" do
      assert Util.is_nil_or_empty(" ")
      assert Util.is_nil_or_empty(nil)
      assert Util.is_nil_or_empty("")
      assert Util.is_nil_or_empty("a") == false
    end
  end

end
