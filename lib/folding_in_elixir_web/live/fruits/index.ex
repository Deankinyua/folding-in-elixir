defmodule FoldingInElixirWeb.FruitsLive.Index do
  @moduledoc """
  Renders Fruits.
  """

  use FoldingInElixirWeb, :live_view

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
    {:ok, socket}
  end
end
