defmodule FoldingInElixirWeb.FruitsLive.NameComponent do
  use FoldingInElixirWeb, :live_component

  alias FoldingInElixir.Market
  alias FoldingInElixir.Market.Customer
  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold>{@title}</Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form to manage Customer records in your database.
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Layout.flex justify_content="start" align_items="center" class="gap-2">
                <Text.text class="text-tremor-content">
                  Customer Name
                </Text.text>
              </Layout.flex>
            </label>

            <.input field={@form[:name]} type="text" placeholder="Customer Name..." />
          </Layout.col>

          <Button.button
            type="submit"
            size="xl"
            class="mt-2 w-min hidden"
            phx-disable-with="Saving..."
          >
            Save Name
          </Button.button>
        </.form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"customer_name" => customer_params}, socket) do
    customer = socket.assigns.customer

    changeset = Market.change_customer_name(customer, customer_params)

    _validity_status =
      case changeset.valid? do
        true ->
          data = changeset.data

          initial_name_map = extract_changeset_data(data)

          name_map = Map.merge(initial_name_map, changeset.changes)

          send(self(), {:valid_name, name_map})

          :ok

        false ->
          :error
      end

    form = to_form(changeset, action: :validate, as: "customer_name")

    {:noreply,
     socket
     |> assign(form: form)}
  end

  @impl true
  def handle_event("save", %{"customer_name" => customer_params}, socket) do
    customer = socket.assigns.customer

    changeset = Market.change_customer_name(customer, customer_params)

    form = to_form(changeset, action: :validate, as: "customer_name")

    {:noreply,
     socket
     |> assign(form: form)}
  end

  defp assign_form(socket) do
    customer = %Customer{}

    socket = create_and_assign_form(socket, customer)
    socket
  end

  defp create_and_assign_form(socket, customer, params \\ %{}) do
    changeset = Market.change_customer_name(customer, params)

    form = to_form(changeset, as: "customer_name")

    socket =
      socket
      |> assign(customer: customer)
      |> assign(form: form)

    socket
  end

  defp extract_changeset_data(data) do
    %{
      name: data.name
    }
  end
end
