defmodule Anagrams.Router do
  use Anagrams.Web, :router

  pipeline :api do
    plug :accepts, ["json"]

    post "/words.json", Anagrams.WordController, :create
    delete "/words.json", Anagrams.WordController, :delete
    resources "/words", Anagrams.WordController, only: [:delete]

    resources "/anagrams", Anagrams.WordController, only: [:show]
  end
end
