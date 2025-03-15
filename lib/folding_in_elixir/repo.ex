defmodule FoldingInElixir.Repo do
  use Ecto.Repo,
    otp_app: :folding_in_elixir,
    adapter: Ecto.Adapters.Postgres
end
