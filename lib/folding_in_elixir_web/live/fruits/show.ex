defmodule FoldingInElixirWeb.FruitsLive.Show do
  @moduledoc """
  Renders Customers' Fruits.
  """

  use FoldingInElixirWeb, :live_view

  alias FoldingInElixir.{Market}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[70%] mx-auto mt-20">
      <Table.table class="w-full">
        <Table.table_head class="rounded-t-md border-b-[1px]">
          <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
            <Table.table_cell>
              <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                Fruit Name
              </Text.text>
            </Table.table_cell>

            <Table.table_cell>
              <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                Quantity
              </Text.text>
            </Table.table_cell>

            <Table.table_cell>
              <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                Price
              </Text.text>
            </Table.table_cell>

            <Table.table_cell>
              <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                Total
              </Text.text>
            </Table.table_cell>
          </Table.table_row>
        </Table.table_head>

        <Table.table_body
          id="table_stream_customers_fruits"
          phx-update="stream"
          class="divide-y overflow-y-auto"
        >
          <Table.table_row
            :for={{dom_id, fruit} <- @streams.fruits}
            id={"#{dom_id}"}
            class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
          >
            <Table.table_cell>
              {fruit.name}
            </Table.table_cell>
            <Table.table_cell>
              {fruit.quantity}
            </Table.table_cell>
            <Table.table_cell>
              {fruit.price}
            </Table.table_cell>
            <Table.table_cell>
              {fruit.total}
            </Table.table_cell>
          </Table.table_row>
        </Table.table_body>
      </Table.table>

      <Button.button size="xl" class="mt-2 w-min">
        <.link navigate={~p"/fruits"}>
          Back to Customers
        </.link>
      </Button.button>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    customer = Market.get_customer(id)
    fruits = customer.fruits

    {:noreply,
     socket
     |> stream(:fruits, fruits)}
  end
end
