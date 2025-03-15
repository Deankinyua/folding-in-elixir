defmodule FoldingInElixir.Helpers do
  def get_map_of_errors(errors) do
    # removes the password key from the keyword list
    messages =
      Enum.reduce(errors, [], fn {_key, value}, acc ->
        [value | acc]
      end)

    # converts the keyword items into a map with atom keys

    result =
      Enum.map(messages, fn {x, y} -> {String.to_atom(x), y} end)
      |> Enum.into(%{})

    result
  end

  def initial_errors() do
    %{
      length: "errors",
      uppercase: "errors",
      number: "errors",
      special: "errors"
    }
  end

  def get_totals(params, count) do
    # count = 2

    # params = %{
    #   "product_1_name" => "orange",
    #   "product_1_price" => "23",
    #   "product_1_quantity" => "34",
    #   "product_1_total" => "",
    #   "product_2_name" => "mango",
    #   "product_2_price" => "67",
    #   "product_2_quantity" => "12",
    #   "product_2_total" => ""
    # }

    list = Enum.to_list(1..count)

    # * Now that we have the list of numbers of the products
    # * we can invoke this function for all the numbers in the list

    list_of_maps_of_products =
      Enum.map(list, fn x ->
        get_total_helper(params, x)
      end)

    final_map_containing_total = merge_individual_maps_to_one(list_of_maps_of_products)

    final_map_containing_total = map_with_string_keys(final_map_containing_total)
    final_map_containing_total
  end

  def get_total_helper(params, count) do
    price = params["product_#{count}_price"]
    price = Integer.parse(price)
    quantity = params["product_#{count}_quantity"]
    quantity = Integer.parse(quantity)

    # * This code here adds a total to each field
    # * in the first iteration to product 1 and in the second iteration to product 2
    # * params is the result

    params =
      case price == :error do
        true ->
          params =
            Map.merge(params, %{"product_#{count}_total" => "quantity and price must be numbers"})

          params

        false ->
          case quantity == :error do
            true ->
              params =
                Map.merge(params, %{
                  "product_#{count}_total" => "quantity and price must be numbers"
                })

              params

            false ->
              total = elem(price, 0) * elem(quantity, 0)

              params = Map.merge(params, %{"product_#{count}_total" => "#{total}"})

              params
          end
      end

    # * Using the unique prefix for fields e.g product_1 this code here
    # * groups each map of a product as its own map
    individual_map_for_product =
      Enum.reduce(params, %{}, fn {key, value}, accumulator_map ->
        case String.starts_with?(key, "product_#{count}") do
          true ->
            Map.put(accumulator_map, key, value)

          false ->
            accumulator_map
        end
      end)

    # * this code transforms our map from having string keys to having atom keys
    # * in preparation for the next step
    individual_map_with_atom_keys =
      Enum.map(individual_map_for_product, fn {x, y} -> {String.to_atom(x), y} end)
      |> Enum.into(%{})

    individual_map_with_atom_keys
  end

  def merge_individual_maps_to_one(list_of_maps) do
    merged_map =
      Enum.reduce(list_of_maps, %{}, fn map, empty_map ->
        Map.merge(empty_map, map)
      end)

    merged_map
  end

  defp map_with_string_keys(map) do
    string_keys_map = Map.new(map, fn {key, value} -> {"#{key}", value} end)
    string_keys_map
  end

  def get_list_of_params(params, count) do
    # params = %{
    #   "product_1_name" => "mango",
    #   "product_1_price" => "54",
    #   "product_1_quantity" => "34",
    #   "product_2_name" => "colgate",
    #   "product_2_price" => "56",
    #   "product_2_quantity" => "43",
    #   "product_3_name" => "apple",
    #   "product_3_price" => "23",
    #   "product_3_quantity" => "19"
    # }

    # count = 2

    list = Enum.to_list(1..count)

    Enum.map(list, fn x ->
      get_map_of_product(params, x)
    end)
  end

  def get_map_of_product(params, count) do
    # * Here we return a list of tuples with each count iteration
    list_of_tuples =
      Enum.reduce(params, [], fn {key, value}, list ->
        case String.starts_with?(key, "product_#{count}") do
          true ->
            prefix = "product_#{count}_"
            key = String.replace_prefix(key, prefix, "")
            # We need to include the count as part of our return value
            [{key, value} | list]

          false ->
            list
        end
      end)

    # * converts the list of tuples into a map with atom keys

    map_of_product =
      Enum.map(list_of_tuples, fn {x, y} -> {String.to_atom(x), y} end)
      |> Enum.into(%{})

    # * adds an error field to detect missing details

    map_of_product =
      case Enum.find(map_of_product, fn {_key, value} ->
             value == "" or value == "quantity and price must be numbers"
           end) do
        nil ->
          map_of_product = Map.put(map_of_product, :errors, false)
          map_of_product

        _ ->
          map_of_product = Map.put(map_of_product, :errors, true)
          map_of_product
      end

    map_of_product
  end
end
