defmodule FoldingInElixirWeb.FruitsLive.FruitComponent do
  use FoldingInElixirWeb, :live_component

  alias FoldingInElixir.{Helpers}

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <p class="text-red-400">{@fruit_error}</p>
        <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <div>
            <%= for fruit <- @fruits do %>
              <Layout.flex
                flex_direction="row"
                align_items="start"
                justify_content="between"
                class="gap-6"
              >
                <Layout.col class="space-y-1.5">
                  <div class={show_errors_on_fruit_field(fruit.id, @list_of_submitted_params)}>
                    <p class="text-red-400">This fruit's fields contains errors</p>
                  </div>
                </Layout.col>
                <Layout.col class="space-y-1.5">
                  <.input field={@form[fruit.name]} type="text" placeholder="Fruit Name..." />
                </Layout.col>
                <Layout.col class="space-y-1.5">
                  <.input field={@form[fruit.quantity]} type="number" placeholder="Quantity..." />
                </Layout.col>
                <Layout.col class="space-y-1.5">
                  <.input field={@form[fruit.price]} type="number" placeholder="Price..." />
                </Layout.col>
                <Layout.col class="space-y-1.5">
                  <.input field={@form[fruit.total]} type="text" readonly placeholder="Total..." />
                </Layout.col>
                <Layout.col class="space-y-1.5">
                  <div class={show_remove_fruit_button(fruit.id, @fruit_count)}>
                    <Button.button
                      variant="secondary"
                      size="xl"
                      class="mt-2 w-min"
                      phx-click={JS.push("remove_fruit", value: %{id: fruit.id})}
                      phx-target={@myself}
                    >
                      Remove Fruit
                    </Button.button>
                  </div>
                </Layout.col>
              </Layout.flex>
            <% end %>
          </div>

          <Button.button
            variant="secondary"
            size="xl"
            class="mt-2 w-min"
            phx-click={JS.push("add_new_fruit")}
            phx-target={@myself}
          >
            New Fruit
          </Button.button>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
            Save and Send
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
     |> assign(:fruits, [])
     |> assign(fruit_count: 0)
     |> assign(list_of_submitted_params: [])
     |> assign(fruit_error: "")
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"fruits" => fruit_params}, socket) do
    # * the main purpose of whatever is here is to offer feedback to the user
    fruit_count = socket.assigns.fruit_count

    fruit_params = remove_unused_fields(fruit_params)

    fruit_params = Helpers.get_totals(fruit_params, fruit_count)

    form = to_form(fruit_params, as: "fruits")

    {:noreply,
     socket
     |> assign(form: form)
     |> assign(fruit_error: "")}
  end

  def handle_event("save", params, socket) do
    case params == %{} do
      true ->
        {:noreply,
         socket
         |> assign(fruit_error: "Please add at least one fruit!")}

      false ->
        %{"fruits" => fruit_params} = params
        count = socket.assigns.fruit_count
        list_of_fruit_params = Helpers.get_list_of_params(fruit_params, count)

        case Enum.find(list_of_fruit_params, fn x -> x.errors == true end) do
          nil ->
            customer = socket.assigns.customer

            send(self(), {:valid_fruit_details, {customer, list_of_fruit_params}})

            {:noreply,
             socket
             |> assign(list_of_submitted_params: [])}

          _map ->
            {:noreply,
             socket
             |> assign(list_of_submitted_params: list_of_fruit_params)}
        end
    end
  end

  @impl true
  def handle_event("add_new_fruit", _params, socket) do
    fruits = socket.assigns.fruits

    count = socket.assigns.fruit_count

    new_count = count + 1

    name = "fruit_" <> Integer.to_string(new_count) <> "_name"
    quantity = "fruit_" <> Integer.to_string(new_count) <> "_quantity"
    price = "fruit_" <> Integer.to_string(new_count) <> "_price"
    total = "fruit_" <> Integer.to_string(new_count) <> "_total"

    new_fruit = %{
      id: new_count,
      name: String.to_atom(name),
      quantity: String.to_atom(quantity),
      price: String.to_atom(price),
      total: String.to_atom(total)
    }

    # to append the new_fruit into our list
    new_fruits = fruits ++ [new_fruit]

    dbg(new_fruits)

    {
      :noreply,
      socket
      |> assign(fruit_count: new_count)
      |> assign(:fruits, new_fruits)
    }
  end

  @impl true
  def handle_event("remove_fruit", %{"id" => id}, socket) do
    fruits = socket.assigns.fruits

    count = socket.assigns.fruit_count

    new_count = count - 1

    fruit =
      Enum.filter(fruits, fn x -> x.id == id end)
      |> Enum.at(0)

    new_fruits =
      Enum.filter(fruits, fn x -> x != fruit end)

    {:noreply,
     socket
     |> assign(fruit_count: new_count)
     |> assign(fruits: new_fruits)}
  end

  defp assign_form(socket) do
    form = to_form(%{}, as: "fruits")

    assign(socket, :form, form)
  end

  defp remove_unused_fields(params) do
    map_of_products =
      Enum.reduce(params, %{}, fn {key, value}, accumulator_map ->
        case String.starts_with?(key, "_unused") do
          true ->
            accumulator_map

          false ->
            Map.put(accumulator_map, key, value)
        end
      end)

    map_of_products
  end

  defp show_remove_fruit_button(id, count) do
    if id == count do
      "block"
    else
      "hidden"
    end
  end

  defp show_errors_on_fruit_field(id, list_of_params) do
    fruit_index = id - 1

    if list_of_params == [] do
      "hidden"
    else
      case Enum.at(list_of_params, fruit_index) do
        nil ->
          "hidden"

        fruit_map ->
          if fruit_map.errors == true do
            "block"
          else
            "hidden"
          end
      end
    end
  end
end
