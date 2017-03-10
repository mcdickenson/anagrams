defmodule Anagrams.WordView do
  use Anagrams.Web, :view

  def render("anagrams.json", %{words: words}) do
    %{
      anagrams: Enum.map(words, &word_json/1)
    }
  end

  def word_json(word) do
    word.word
  end
end
