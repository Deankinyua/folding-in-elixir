defmodule FoldingInElixirWeb.FruitsLive.Index do
  @moduledoc """
  Renders Fruits.
  """

  use FoldingInElixirWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      List of Customers and the fruits they bought
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
