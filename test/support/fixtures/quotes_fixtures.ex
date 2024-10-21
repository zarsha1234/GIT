defmodule Roc.QuotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Roc.Quotes` context.
  """

  @doc """
  Generate a quote.
  """
  def quote_fixture(attrs \\ %{}) do
    {:ok, quote} =
      attrs
      |> Enum.into(%{
        author: "some author",
        quote: "some quote",
        source: "some source"
      })
      |> Roc.Quotes.create_quote()

    quote
  end
end
