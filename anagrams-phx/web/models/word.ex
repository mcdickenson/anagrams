defmodule Anagrams.Word do
  use Anagrams.Web, :model

  schema "words" do
    field :key, :string
    field :word, :string

    timestamps
  end
end