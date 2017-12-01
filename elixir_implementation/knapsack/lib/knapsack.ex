defmodule Knapsack do

  @nPopulation 200
  @percent_of_selection 20
  @percent_of_mutation 5

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
    items = Item.parse(items) |> Item.sort_by_price
    {create_population([], items, 0, carrying, capacity, 0), length(items)}
    # |> Enum.map(fn x -> convert_to_gen(x, length(items))  end)
  end

  def create_population(population, items, first_item, carrying, capacity, nPopulation) 
    when nPopulation < @nPopulation do
      item = items |> Enum.at(first_item)    
      create_population(population ++ [create_individual(items, [item.index], item.carrying, 
        item.capacity, item.price,
        carrying, capacity)], 
        items, 
        (if first_item + 1 < length(items), do: first_item + 1, else: 0), 
        carrying, capacity, nPopulation + 1)
  end

  def create_population(population, items, first_item, carrying, capacity, nPopulation) do
      population
  end

  def create_individual(items, new_list, currentCarrying, currentCapacity, currentPrice, carrying, capacity) do
      new_item_index = (if List.last(new_list) + 1 < length(items), do: List.last(new_list) + 1, else: 0)
      new_item = Enum.at(items,  new_item_index)
      if currentCarrying + new_item.carrying < carrying 
        and currentCapacity + new_item.capacity do
          create_individual(items, 
            new_list ++ [new_item.index], currentCarrying + new_item.carrying, 
            currentCapacity + new_item.capacity, currentPrice + new_item.price,
            carrying, capacity)
      else
        %Individual{gen: new_list, carrying: currentCarrying, capacity: currentCapacity, price: currentPrice}
      end
  end

  def list_to_gen(set_of_items, n) do
    0..n-1 |> 
    Enum.map(fn x -> if Enum.member?(set_of_items, x), do: 1, else: 0 end)  
  end

  def gen_to_list(set_of_items, n) do
    0..n-1 |> 
    Enum.map(fn x -> if Enum.member?(set_of_items, x), do: 1, else: 0 end)  
  end

  def selection(population) do
    {population, length_of_gen} = population
    l = round(length_of_gen / 4)
    nIndividuals = round(@nPopulation / 100) * @percent_of_selection
    population = population |> 
    Enum.sort(&(&1.price > &2.price)) |>
    Enum.map(fn list -> list_to_gen(list.gen, length_of_gen) end)

    best = population |> Enum.take(nIndividuals) 

    new = best |> 
    Enum.take(round(nIndividuals / 2)) |> 
    Enum.with_index(round(nIndividuals / 2)) |>
    Enum.flat_map(fn x -> 
      {male, female_index} = x
      female = Enum.at(best, female_index)

      a = Enum.slice(male, 0, l)
      b = Enum.slice(male, l, l)
      c = Enum.slice(male, 2*l, l)
      d = Enum.slice(male, 3*l, nIndividuals - 3*l)

      e = Enum.slice(female, 0, l)
      f = Enum.slice(female, l, l)
      g = Enum.slice(female, 2*l, l)
      h = Enum.slice(female, 3*l, nIndividuals - 3*l)

      [a ++ b ++ e ++ f, c ++ d ++ g ++ h]
    end) 

    new ++ Enum.slice(population, nIndividuals, @nPopulation - nIndividuals)
  end

  def mutation(population) do
    old = population |>
    Enum.take_random(round(@nPopulation / 100) * @percent_of_mutation)

    new = old |>
    Enum.map(fn x -> 
      random_bytes = Enum.take_random(1..length(x), 3)
      List.update_at(x, Enum.at(random_bytes, 0), &(if &1 == 0, do: 1, else: 0)) |>
      List.update_at(Enum.at(random_bytes, 1), &(if &1 == 0, do: 1, else: 0)) |>
      List.update_at(Enum.at(random_bytes, 2), &(if &1 == 0, do: 1, else: 0))
    end)
    population = population -- old
    population ++ new
  end

  def solve do
    "../../38.txt" |> 
    read |>
    generate_population |>
    selection |>
    mutation |> length
    #crossingover |>
    #mutations |>
    #generate_new_individuals |>

  end

end
