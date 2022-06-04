defmodule LiveMenuOrderWeb.PageController do
  use LiveMenuOrderWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
