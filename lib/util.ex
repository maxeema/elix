defmodule Util do

  def parse_url(url) do
    if is_nil_or_empty(url) do
      %URI{}
    else
      case URI.parse(url |> :string.trim) do
        %URI{scheme: nil} -> parse_url("http://#{url}")
        parsed -> parsed
      end
    end
  end

  def url_host(url) do parse_url(url).host end


  def is_not_empty(str) do !is_nil_or_empty(str) end
  def is_nil_or_empty(str) do
    is_nil(str) || :string.trim(str) |> :string.is_empty
  end

end