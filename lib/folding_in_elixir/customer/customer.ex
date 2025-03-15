defmodule FoldingInElixir.Market.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "customers" do
    field :name, :string

    timestamps(type: :utc_datetime)

    embeds_many :fruits, FoldingInElixir.Market.Fruit
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :name
    ])
    |> validate_required([
      :name
    ])
    |> cast_embed(:fruits)
  end
end
