defmodule Anagrams.PageController do
  use Anagrams.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
