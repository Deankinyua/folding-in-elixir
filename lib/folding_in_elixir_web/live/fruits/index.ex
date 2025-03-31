defmodule FoldingInElixirWeb.FruitsLive.Index do
  @moduledoc """
  Renders Customers.
  """

  use FoldingInElixirWeb, :live_view

  alias FoldingInElixir.{Repo, Market}

  alias FoldingInElixir.Market.Customer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="w-[95%] mx-auto">
        <Layout.flex flex_direction="row" justify_content="between">
          <Layout.flex flex_direction="col" class="mt-20">
            <div class="hidden sm:block">
              <Button.button
                class="bg-[#7c5dfa] rounded-full pl-2"
                phx-click={JS.patch(~p"/fruits/new")}
              >
                <Layout.flex flex_direction="row" justify_content="between" class="gap-4">
                  <div><img src={~p"/images/fruits/plusbutton.svg"} alt="invoice button" /></div>
                  <div>New Customer</div>
                </Layout.flex>
              </Button.button>
            </div>

            <div class="sm:hidden">
              <Button.button
                class="bg-[#7c5dfa] rounded-full pl-2"
                phx-click={JS.patch(~p"/fruits/new")}
              >
                <Layout.flex flex_direction="row" justify_content="between" class="gap-4">
                  <div><img src={~p"/images/fruits/plusbutton.svg"} alt="invoice button" /></div>

                  <div>New</div>
                </Layout.flex>
              </Button.button>
            </div>
          </Layout.flex>
        </Layout.flex>

        <%= if  @streams.customers.inserts == [] do %>
          <Layout.flex flex_direction="col" justify_content="center">
            <Text.subtitle color="black" class="text-2xl font-semibold py-6">
              There is nothing here.
            </Text.subtitle>
            <Text.text>Create a customer and their fruits. Get started by clicking</Text.text>
            <Text.text>New Customer</Text.text>
          </Layout.flex>
        <% end %>
        <Table.table class="w-full">
          <Table.table_head class="rounded-t-md border-b-[1px]">
            <Table.table_row class="hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted">
              <Table.table_cell>
                <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis">
                  Customer Name
                </Text.text>
              </Table.table_cell>

              <Table.table_cell>
                <Text.text class="font-semibold text-tremor-content-emphasis dark:text-dark-tremor-content-emphasis text-center">
                  Actions
                </Text.text>
              </Table.table_cell>
            </Table.table_row>
          </Table.table_head>

          <Table.table_body
            id="table_stream_customers"
            phx-update="stream"
            class="divide-y overflow-y-auto"
          >
            <Table.table_row
              :for={{dom_id, customer} <- @streams.customers}
              id={dom_id}
              class="group hover:bg-tremor-background-muted dark:hover:bg-dark-tremor-background-muted"
            >
              <.live_component
                module={FoldingInElixirWeb.FruitsLive.RowComponent}
                id={dom_id}
                customer={customer}
                dom_id={dom_id}
              >
                <Table.table_cell>
                  {customer.name}
                </Table.table_cell>
              </.live_component>
            </Table.table_row>
          </Table.table_body>
        </Table.table>

        <.modal
          :if={@live_action in [:new, :edit]}
          id="fruits-modal"
          show
          on_cancel={JS.patch(~p"/fruits")}
        >
          <.live_component
            module={FoldingInElixirWeb.FruitsLive.NameComponent}
            id="customer name form"
            title={@page_title}
            action={@live_action}
            customer={@customer}
            patch={~p"/fruits"}
          />

          <.live_component
            module={FoldingInElixirWeb.FruitsLive.FruitComponent}
            id="fruits form"
            action={@live_action}
            customer={@customer}
            patch={~p"/fruits"}
          />
        </.modal>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    customers = Repo.all(Customer)

    {:ok,
     socket
     |> stream(
       :customers,
       customers
     ), layout: {FoldingInElixirWeb.Layouts, :root}}
  end

  @impl true
  def handle_info({:customer, customer}, socket) do
    {:noreply, stream_insert(socket, :customers, customer)}
  end

  @impl true
  def handle_info({:valid_name, name_details}, socket) do
    {:noreply,
     socket
     |> assign(name_details: name_details)}
  end

  @impl true
  def handle_info({:valid_fruit_details, details}, socket) do
    {customer, fruit_details} = details

    fruit_details = delete_errors_key(fruit_details)

    fruit_details = %{
      fruits: fruit_details
    }

    case Map.get(socket.assigns, :name_details) do
      nil ->
        if customer != nil do
          name_details = %{name: customer.name}

          submit_details(customer, name_details, fruit_details, socket)
        else
          {:noreply, socket}
        end

      name_details ->
        submit_details(customer, name_details, fruit_details, socket)
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"customer_id" => id}, socket) do
    customer = Repo.get!(Customer, id)

    Repo.delete(customer)

    {:noreply, stream_delete(socket, :customers, customer)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    customer = Market.get_customer(id)

    socket
    |> assign(:page_title, "Edit Customer")
    |> assign(:customer, customer)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Customers")
  end

  defp delete_errors_key(fruit_details) do
    fruit_details =
      Enum.map(fruit_details, fn map ->
        Map.delete(map, :errors)
      end)

    fruit_details
  end

  defp submit_details(customer, name_details, fruit_details, socket) do
    complete_customer_data = Map.merge(name_details, fruit_details)

    case customer == nil do
      true ->
        customer_changeset = Market.change_customer(%Customer{}, complete_customer_data)

        case Repo.insert(customer_changeset) do
          {:ok, record} ->
            send(self(), {:customer, record})

            {:noreply,
             socket
             |> push_patch(to: ~p"/fruits")
             |> put_flash(:info, "Customer Details were successfully added")}

          {:error, _changeset} ->
            {:noreply,
             socket
             |> push_patch(to: ~p"/fruits")
             |> put_flash(:error, "Customer Details were not submitted!!")}
        end

      false ->
        customer_changeset = Market.change_customer(customer, complete_customer_data)

        case Repo.update(customer_changeset) do
          {:ok, record} ->
            send(self(), {:customer, record})

            {:noreply,
             socket
             |> push_patch(to: ~p"/fruits")
             |> put_flash(:info, "Customer Details were successfully updated")}

          {:error, _changeset} ->
            {:noreply,
             socket
             |> push_patch(to: ~p"/fruits")
             |> put_flash(:error, "Customer Details were not updated!!")}
        end
    end
  end
end
