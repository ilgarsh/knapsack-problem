defmodule Knapsack do

  def read(path_to_file) do
    {:ok, data} = File.read(path_to_file)

    Regex.split(~r{( |\n)}, data) |>
    Enum.map(fn x -> 
      {num, _} = Float.parse(x)
      num
     end) |>
    Enum.with_index(-2)
  end

  def generate_population(list) do
    [carrying, capacity | items] = list
    {carrying, _} = carrying
    {capacity, _} = capacity
    items = Item.parse(items)
    create_population([], items, 0, carrying, capacity, 0) |>
    Enum.map(fn x -> convert_to_gen(x, length(items))  end)
  end

  def create_population(population, items, first_item, carrying, capacity, nPopulation) when nPopulation < 200 do
      item = items |> Enum.at(first_item)    
      create_population(population ++ [create_individual(items, [item.id], item.carrying, item.capacity, carrying, capacity)], 
        items, 
        (if first_item + 1 < length(items), do: first_item + 1, else: 0), 
        carrying, capacity, nPopulation + 1)
  end

  def create_population(population, items, first_item, carrying, capacity, nPopulation) do
      population
  end

  def create_individual(items, new_list, currentCarrying, currentCapacity, carrying, capacity) 
    when currentCarrying < carrying and currentCapacity < capacity do
      new_item = Enum.at(items, (if List.last(new_list) + 1 < length(items), do: List.last(new_list) + 1, else: 0) )
      create_individual(items, new_list ++ [new_item.id], currentCarrying + new_item.carrying, currentCapacity + new_item.capacity,
        carrying, capacity) 
  end

  def create_individual(items, new_list, currentCarrying, currentCapacity, carrying, capacity) do
    new_list
  end

  def convert_to_gen(set_of_items, n) do
    0..n-1 |> 
    Enum.map(fn x -> if Enum.member?(set_of_items, x), do: 1, else: 0 end) 
  end

  def solve do
    "../../38.txt" |> 
    read |>
    generate_population 
    #selection |>
    #crossingover |>
    #mutations |>
    #generate_new_individuals |>

  end

end
