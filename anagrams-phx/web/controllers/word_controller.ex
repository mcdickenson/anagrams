defmodule Anagrams.WordController do
  use Anagrams.Web, :controller

  defp saveWord(word) do
    word = %Anagrams.Word{key: wordToKey(word), word: word}
    Anagrams.Repo.insert(word)
  end

  defp wordToKey(word) do
    String.split(word, "") |> Enum.sort |> Enum.join
  end

  def create(conn, params) do
    params["words"] |> Enum.map(&saveWord/1)

    conn
    |> send_resp(201, "")
  end

  def show(conn, params) do
    [id, _] = String.split(params["id"], ".json")
    key = wordToKey(id)

    query = from w in Anagrams.Word, where: w.key == ^key, where: w.word != ^id

    # optional limit parameter
    if params["limit"] do
      limit = String.to_integer(params["limit"])
      query = from query, limit: ^limit
    end

    words = query |> Anagrams.Repo.all

    render conn, "anagrams.json", words: words
  end

  def delete(conn, params) do
    response_code = 204
    query = from w in Anagrams.Word

    if params["id"] do
      response_code = 200
      [id, _] = String.split(params["id"], ".json")
      query = from w in query, where: w.word == ^id
    end

    Anagrams.Repo.delete_all(query)

    conn
    |> send_resp(response_code, "")
  end
end
