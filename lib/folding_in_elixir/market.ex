defmodule FoldingInElixir.Records do
  @moduledoc """
  The Market context.
  """

  import Ecto.Query, warn: false
  alias FoldingInElixir.Repo

  alias FoldingInElixir.Market.{Customer, Fruit}

  def list_customers do
    Repo.all(Customer)
  end

  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  def change_customer_name(%Customer{} = customer_name, attrs \\ %{}) do
    Customer.name_changeset(customer_name, attrs)
  end

  def change_customer_fruits(%Fruit{} = customer_fruit, attrs \\ %{}) do
    Fruit.changeset(customer_fruit, attrs)
  end
end
