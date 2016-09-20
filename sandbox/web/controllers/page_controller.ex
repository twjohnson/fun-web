defmodule Secounter.PageController do
  use Secounter.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
