defmodule Bleacherbot.PageController do
  use Bleacherbot.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
