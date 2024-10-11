defmodule Roc.Repo do
  use Ecto.Repo,
    otp_app: :roc,
    adapter: Ecto.Adapters.Postgres
end
