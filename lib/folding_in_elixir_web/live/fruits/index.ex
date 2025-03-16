defmodule FoldingInElixirWeb.FruitsLive.Index do
  @moduledoc """
  Renders Fruits.
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

        <Layout.flex flex_direction="col" justify_content="center">
          <Text.subtitle color="black" class="text-2xl font-semibold py-6">
            There is nothing here.
          </Text.subtitle>
          <Text.text>Create a customer and their fruits. Get started by clicking the</Text.text>
          <Text.text>New button</Text.text>
        </Layout.flex>

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
            patch={~p"/fruits"}
          />

          <.live_component
            module={FoldingInElixirWeb.FruitsLive.FruitComponent}
            id="fruits form"
            action={@live_action}
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

    dbg(customers)

    {:ok, socket}
  end

  @impl true
  def handle_info({:valid_name, name_details}, socket) do
    {:noreply,
     socket
     |> assign(name_details: name_details)}
  end

  @impl true
  def handle_info({:valid_fruit_details, fruit_details}, socket) do
    fruit_details = delete_errors_key(fruit_details)

    case Map.get(socket.assigns, :name_details) do
      nil ->
        {:noreply, socket}

      name_details ->
        fruit_details = %{
          fruits: fruit_details
        }

        complete_customer_data = Map.merge(name_details, fruit_details)

        customer_changeset = Market.change_customer(%Customer{}, complete_customer_data)

        case Repo.insert(customer_changeset) do
          {:ok, _record} ->
            {:noreply,
             socket
             |> push_patch(to: ~p"/fruits")
             |> put_flash(:info, "Customer was Successfully added")}

          {:error, _changeset} ->
            {:noreply,
             socket
             |> push_patch(to: ~p"/fruits")
             |> put_flash(:error, "Customer Details were not Submitted!!")}
        end
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Edit Customer")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
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
end
