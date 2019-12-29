defmodule Server.Test do
  use ExUnit.Case, async: true

  @server_port "8080"

  @links_body "{ \"links\": [ null, \"https://fb.com/cool\", \"\", \" \", \"https://bing.com?search=cats\", \"fb.com\", \"https://stackoverflow.com/questions/0\" ] }"
  @links_headers [{"Content-type", "application/json"}]

  setup_all do
    assert Redix.command!(:redix, ["flushall"]) == "OK"
    assert Redix.command!(:redix, ["dbsize"]) == 0
    {:ok, %{port: @server_port}}
  end

  describe "-requests-" do

    test "get visited_domains empty", %{port: port} do
      now = DateTime.utc_now() |> DateTime.to_unix()
      {status, resp} = HTTPoison.get("localhost:#{port}/visited_domains?from=0&to=#{now}")
      assert status == :ok
      assert resp.status_code == 200
      json = JSON.decode!(resp.body)
      assert json["status"] == "ok"
      assert json["domains"] |> Enum.empty?
    end

    test "post visited_links", %{port: port} do
      assert Redix.command!(:redix, ["flushall"]) == "OK"
      assert Redix.command!(:redix, ["dbsize"]) == 0
      try do
        {status, resp} = HTTPoison.post("localhost:#{port}/visited_links", @links_body, @links_headers)
        assert status == :ok
        assert resp.status_code == 200
        json = JSON.decode!(resp.body)
        assert json["status"] == "ok"
        assert Redix.command!(:redix, ["dbsize"]) == 4
        #
        now = DateTime.utc_now() |> DateTime.to_unix()
        {status, resp} = HTTPoison.get("localhost:#{port}/visited_domains?from=0&to=#{now}")
        assert status == :ok
        assert resp.status_code == 200
        json = JSON.decode!(resp.body)
        assert is_list(json["domains"])
        assert Enum.count(json["domains"]) == 3
      after
        assert Redix.command!(:redix, ["flushall"]) == "OK"
      end
    end

    test "check unsupported root path", %{port: port} do
      {status, resp} = HTTPoison.get("localhost:#{port}")
      assert status == :ok
      assert resp.status_code == 200
      json = JSON.decode!(resp.body)
      assert json["status"] == "error"
      assert json["reason"] == "unsupported request"
    end

    test "check unsupported wrong path", %{port: port} do
      {status, resp} = HTTPoison.get("localhost:#{port}/sdfjhhqhfq/12346?sdaf&jh17#")
      assert status == :ok
      assert resp.status_code == 200
      json = JSON.decode!(resp.body)
      assert json["status"] == "error"
      assert json["reason"] == "unsupported request"
    end
  end

end
