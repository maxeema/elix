defmodule Server do
  use Ace.HTTP.Service, port: 8080, cleartext: true
  use Raxx.SimpleServer

  def handle_request(%{method: :GET, path: ["visited_domains"], query: query}, _state) do
    IO.puts "> visited_domains, #{query}"
    now = DateTime.utc_now() |> DateTime.to_unix()
    IO.puts " - now: #{now} -> #{DateTime.utc_now()}"
    #
    try do
      query_map = URI.decode_query(query)
      Enum.count(query_map) == 2 or raise ArgumentError, message: "only %from%, %to% args should be"

      from = query_map |> Map.get("from", "") #|> String.to_integer # |> DateTime.from_unix!
      Regex.match?(~r/^\d+$/, from) or raise ArgumentError, message: "%from% arg should be number"
      from = Integer.parse(from) |> elem(0)

      to = query_map |> Map.get("to", "")
      Regex.match?(~r/^\d+$/, to) or raise ArgumentError, message: "%to% arg should be number"
      to = Integer.parse(to) |> elem(0)

      domains = Redix.command!(:redix, ["keys", "*"])
                |> Enum.filter(fn url -> (Redix.command!(:redix, ["get", url]) |> String.to_integer) in from..to end )
                |> Enum.map(&Util.url_host/1)
                |> Enum.uniq()
      prepare_good_response(JSON.encode!([
        status: "ok",
        domains: domains,
      ]))
    rescue
      e -> prepare_bad_response(e)
    end
  end

  def handle_request(%{method: :POST, path: ["visited_links"], body: body}, _state) do
    IO.puts "> visited_links"
    try do
      {status, json} = JSON.decode(body)
      status == :ok && is_list(json["links"]) or raise ArgumentError, message: "wrong data"

      date = DateTime.utc_now() |> DateTime.to_unix()

      json["links"]
      |> Stream.filter(&Util.is_not_empty/1)
      |> Stream.map(&Util.parse_url/1)
      |> Stream.each(fn url ->
#          IO.puts("url: #{url}")
          Redix.command!(:redix, ["set", url, date])
        end)
      |> Stream.run

      IO.puts " - new db size: #{Redix.command!(:redix, ["dbsize"])}"

#      cmds = for link <- json["links"] do ["set", Util.parse_url(link), date] end
#      Redix.pipeline!(:redix, cmds)

      prepare_good_response(JSON.encode!([
        status: "ok"
      ]))
      rescue
        e -> prepare_bad_response(e)
    end
  end

  def handle_request(request, _state) do
    IO.puts "> #{request.raw_path}\n< error"
    response(:ok)
    |> set_header("content-type", "text/json")
    |> set_body(JSON.encode!([
      status: "error",
      reason: "unsupported request",
    ]))
  end

  ###

  defp prepare_good_response(json) do
    IO.puts "< ok"
    response(:ok)
    |> set_header("content-type", "text/json")
    |> set_body(json)
  end

  defp prepare_bad_response(e) do
    t = e.__struct__
    error = cond do
      t == Redix.ConnectionError ->
        {"db error", "can't connect because of: #{e.reason}"}
      t == Redix.Error ->
        {"db error", e.message}
      t == ArgumentError ->
        {"arg error", e.message}
      true ->
        {"internal error", "we're already fixing it"}
    end
    #
    try do IO.puts "< error, #{error |> elem(0)} -> #{error |> elem(1)}" rescue _e -> "" end
    #
    response(:ok) #response(:bad_request)
    |> set_header("content-type", "text/json")
    |> set_body(JSON.encode!([
      status: "error",
      reason: error |> elem(0),
      details: error |> elem(1)
    ]))
  end

end

