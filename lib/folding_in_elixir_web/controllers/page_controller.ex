defmodule FoldingInElixirWeb.PageController do
  use FoldingInElixirWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/fruits")
  end
end
