alias Roc.Quotess.Quotes

# Read quotes from the JSON file
quotes_path = "priv/repo/quotes.json"
quotes_path
|> File.read!()
|> Jason.decode!()
|> Enum.each(fn attrs ->
	# Construct a quote struct and attempt to insert it
	quote = %{quote: attrs["quote"], author: attrs["author"], source: attrs["source"]}
	case Quotes.create_quote(quote) do
		{:ok, _quote} -> :ok
		{:error, _changeset} -> :duplicate
	end
end)
# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Roc.Repo.insert!(%Roc.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
