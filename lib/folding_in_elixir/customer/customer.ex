defmodule FoldingInElixir.Market.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "customers" do
    field :name, :string

    timestamps(type: :utc_datetime)

    embeds_many :fruits, FoldingInElixir.Market.Fruit, on_replace: :delete
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :name
    ])
    |> validate_required(:name)
    |> validate_name()
    |> cast_embed(:fruits)
  end

  def name_changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :name
    ])
    |> validate_required(:name)
    |> validate_name()
  end

  def validate_name(changeset) do
    changeset
    |> validate_length(:name,
      min: 4,
      max: 60,
      message: "the name must be between 4 and 20 characters long"
    )
  end
end
