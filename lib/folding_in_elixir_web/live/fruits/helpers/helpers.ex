defmodule FoldingInElixir.Helpers do
  def get_totals(params, count) do
    # count = 2

    # params = %{
    #   "fruit_1_name" => "orange",
    #   "fruit_1_price" => "23",
    #   "fruit_1_quantity" => "34",
    #   "fruit_1_total" => "",
    #   "fruit_2_name" => "mango",
    #   "fruit_2_price" => "67",
    #   "fruit_2_quantity" => "12",
    #   "fruit_2_total" => ""
    # }

    list = Enum.to_list(1..count)

    # * Now that we have the list of the number of fruits
    # * we can invoke this function for all the numbers in <list>

    list_of_maps_of_fruits =
      Enum.map(list, fn x ->
        get_total_helper(params, x)
      end)

    final_map_containing_total = merge_individual_maps_to_one(list_of_maps_of_fruits)

    final_map_containing_total = map_with_string_keys(final_map_containing_total)
    final_map_containing_total
  end

  def get_total_helper(params, count) do
    price = params["fruit_#{count}_price"]
    price = Integer.parse(price)
    quantity = params["fruit_#{count}_quantity"]
    quantity = Integer.parse(quantity)

    # * This code here adds a total to each field
    # * In each iteration a total field is added to the respective fruit
    # * params is the result

    params =
      case price == :error do
        true ->
          params =
            Map.merge(params, %{"fruit_#{count}_total" => "quantity and price must be numbers"})

          params

        false ->
          case quantity == :error do
            true ->
              params =
                Map.merge(params, %{
                  "fruit_#{count}_total" => "quantity and price must be numbers"
                })

              params

            false ->
              # Because Integer.parse returns a 2-element tuple
              total = elem(price, 0) * elem(quantity, 0)

              params = Map.merge(params, %{"fruit_#{count}_total" => "#{total}"})

              params
          end
      end

    # * Using the unique prefix for fields e.g fruit_1
    # * this code here groups each map of a fruit as its own map
    individual_map_for_fruit =
      Enum.reduce(params, %{}, fn {key, value}, accumulator_map ->
        case String.starts_with?(key, "fruit_#{count}") do
          true ->
            Map.put(accumulator_map, key, value)

          false ->
            accumulator_map
        end
      end)

    # * this code transforms our map from having string keys to having atom keys
    # * in preparation for the next step
    individual_map_with_atom_keys =
      Enum.map(individual_map_for_fruit, fn {x, y} -> {String.to_atom(x), y} end)
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
    list = Enum.to_list(1..count)

    Enum.map(list, fn x ->
      get_map_of_fruit(params, x)
    end)
  end

  def get_map_of_fruit(params, count) do
    # * Here we return a list of tuples with each count iteration
    list_of_tuples =
      Enum.reduce(params, [], fn {key, value}, list ->
        case String.starts_with?(key, "fruit_#{count}") do
          true ->
            prefix = "fruit_#{count}_"
            key = String.replace_prefix(key, prefix, "")
            # We need to include the count as part of our return value
            [{key, value} | list]

          false ->
            list
        end
      end)

    # * converts the list of tuples into a map with atom keys

    map_of_fruit =
      Enum.map(list_of_tuples, fn {x, y} -> {String.to_atom(x), y} end)
      |> Enum.into(%{})

    # * adds an error field to detect missing details

    map_of_fruit =
      case Enum.find(map_of_fruit, fn {_key, value} ->
             value == "" or value == "quantity and price must be numbers"
           end) do
        nil ->
          map_of_fruit = Map.put(map_of_fruit, :errors, false)
          map_of_fruit

        _ ->
          map_of_fruit = Map.put(map_of_fruit, :errors, true)
          map_of_fruit
      end

    map_of_fruit
  end
end
