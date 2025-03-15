defmodule FoldingInElixir.Repo.Migrations.AddCustomer do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :fruits, :map
      timestamps(type: :utc_datetime)
    end
  end
end
