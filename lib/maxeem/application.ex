defmodule Maxeem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  def start(_type, _args) do

    children = [
      {Redix, name: :redix},
      {Server, args: nil},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Maxeem.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
