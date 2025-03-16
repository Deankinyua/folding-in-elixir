defmodule FoldingInElixirWeb.FruitsLive.RowComponent do
  use FoldingInElixirWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      {render_slot(@inner_block)}

      <Table.table_cell>
        <div class="flex justify-between px-6">
          <Button.button>
            <.link navigate={~p"/fruits/#{@customer}"}>
              View Fruits
            </.link>
          </Button.button>

          <Button.button>
            <.link navigate={~p"/fruits/#{@customer.id}/edit"}>
              Edit Fruits
            </.link>
          </Button.button>
          <Button.button>
            <.link phx-click={
              JS.push("delete", value: %{dom_id: @dom_id, customer_id: @customer.id})
              |> hide("##{@dom_id}")
            }>
              Delete
            </.link>
          </Button.button>
        </div>
      </Table.table_cell>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
