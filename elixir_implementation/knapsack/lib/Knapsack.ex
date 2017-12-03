defmodule Knapsack do
  @moduledoc """
  This is Knapsack module that solves 
    Knapsack problem using Genetic Algorithms.

  ## Examples

    ## Finds the best set of items
    iex> Knapsack.find

    %Individual{bit_sequence: [1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0,
    0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0], capacity: 10.6, carrying: 12451.0,
    items: [0, 1, 2, 6, 7, 9, 10, 11, 15, 21, 24, 25, 26, 28], price: 4388.0}

    

    ## Run algorithm nth time and return the best of the best results of algorithm's work
    iex> Knapsack.run_nth_time(100)

    %Individual{bit_sequence: [1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0,
    0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0], capacity: 11.999999999999998,
    carrying: 12987.0,
    items: [0, 1, 2, 4, 6, 7, 9, 10, 11, 15, 21, 24, 25, 27, 28], price: 4537.0}

  """

  @nPopulation 200
  @percent_of_selection 20
  @percent_of_mutation 5
  @nGens 100
  @percent_of_convergence 0.1

  @doc """
  Read txt file and return list with index.
  """
  defp read(path_to_file) do
    {:ok, data} = File.read(path_to_file)

    Regex.split(~r{( |\n)}, data) |>
    Enum.map(fn x -> 
      {num, _} = Float.parse(x)
      num
     end) |>
    Enum.with_index(-2) ## first and second elements are max carrying and capacity
  end

  @doc """
  Converting simple list to item's list, sorting and run create_population.
  """
  defp generate_population(list) do
    [carrying, capacity | items] = list
    {carrying, _} = carrying
    {capacity, _} = capacity
    items = Item.parse(items) 
    sorted_items = items |> Item.sort_by_price
    {create_population([], sorted_items, 0, carrying, capacity, 0), length(sorted_items), items, 
      carrying, capacity}
  end

  @doc """
  Create population from item's list while population < @nPopulation.
  """
  defp create_population(population, items, first_item, carrying, capacity, nPopulation) 
    when nPopulation < @nPopulation do
      item = items |> Enum.at(first_item)    
      create_population(population ++ [create_individual(items, List.duplicate(0, 30), 0, item.carrying, 
        item.capacity, item.price,
        carrying, capacity)], 
        items, 
        (if first_item + 1 < length(items), do: first_item + 1, else: 0), 
        carrying, capacity, nPopulation + 1)
  end

  @doc """
  Return population when population == @nPopulation.
  """
  defp create_population(population, items, first_item, carrying, capacity, nPopulation) do
      population
  end

  @doc """
  Create one individual.
  """
  defp create_individual(items, bit_sequence, new_item_index, currentCarrying, currentCapacity, currentPrice, carrying, capacity) do
      new_item = Enum.at(items,  new_item_index)
      if currentCarrying + new_item.carrying < carrying 
        and currentCapacity + new_item.capacity do
          create_individual(items, 
            List.replace_at(bit_sequence, new_item.id, 1),
            new_item_index + 1,
            currentCarrying + new_item.carrying, 
            currentCapacity + new_item.capacity, currentPrice + new_item.price,
            carrying, capacity)
      else
        %Individual{bit_sequence: bit_sequence, carrying: currentCarrying, capacity: currentCapacity, price: currentPrice}
      end
  end

  @doc """
  Sorting population by price and save bit sequence.
  Then divides the bit sequence into 4 parts and crosses two individuals.
  """
  defp selection_and_crossingover(population) do
    {population, length_of_sequence, items, max_carrying, max_capacity} = population

    population = population |> 
    Enum.sort(&(&1.price > &2.price)) |>
    Enum.map(fn x -> x.bit_sequence end)

    l = trunc(length_of_sequence / 4)
    nIndividuals = trunc(@nPopulation / 100) * @percent_of_selection
    best = population |> Enum.take(nIndividuals) 

    new = best |> 
    Enum.take(trunc(nIndividuals / 2)) |> 
    Enum.with_index(trunc(nIndividuals / 2)) |>
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

      [a ++ f ++ c ++ h, e ++ b ++ g ++ d]
    end) 

    {new ++ Enum.slice(population, nIndividuals, @nPopulation - nIndividuals), length_of_sequence, items,
      max_carrying, max_capacity}
  end

  @doc """
  Finds random individuals and inverts 3 random bits.
  """
  defp mutation(population) do
    {population, length, items, max_carrying, max_capacity} = population
    old = population |>
    Enum.take_random(trunc(@nPopulation / 100) * @percent_of_mutation)

    new = old |>
    Enum.map(fn x -> 
      random_bytes = Enum.take_random(0..length(x)-1, 3)
      List.update_at(x, Enum.at(random_bytes, 0), &(if &1 == 0, do: 1, else: 0)) |>
      List.update_at(Enum.at(random_bytes, 1), &(if &1 == 0, do: 1, else: 0)) |>
      List.update_at(Enum.at(random_bytes, 2), &(if &1 == 0, do: 1, else: 0))
    end)
    population = population -- old
    {Individual.parse(population ++ new, items, max_carrying, max_capacity), 
      length, items, max_carrying, max_capacity}
  end 

  @doc """
  Generate population while iterator < @nGens or convergence has come.
  """
  defp find(data, iterator, best_old, best_new) 
    when iterator < @nGens and abs(best_old/best_new) < @percent_of_convergence do
      {population, _, _, _, _} = data 
      best_old = best_new
      best_new = population |> get_best

      data |>
      selection_and_crossingover |>
      mutation |>
      find(iterator + 1, best_old, best_new)
  end

  @doc """
  Find population and return the best individual from population.
  """
  defp find(data, iterator, best_old, best_new) do
    {population, _, _, _, _} = data
    population |> get_best
  end 
  
  @doc """
  Find and return the best individual in population.
  """
  defp get_best(population) do
    population |>
    Enum.sort(&(&1.price > &2.price)) |>
    List.first |> Individual.update_item_indexes
  end

  @doc """
  Main function in module.
  Finds the best Knapsack problem solution.

  ## Examples

    iex> Knapsack.find

    %Individual{bit_sequence: [1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0,
    0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0], capacity: 10.6, carrying: 12451.0,
    items: [0, 1, 2, 6, 7, 9, 10, 11, 15, 21, 24, 25, 26, 28], price: 4388.0}

  """
  def find do
    "../../38.txt" |> 
    read |> 
    generate_population |>
    ## second and third params is a old element price and new element price.
    ## They are needed for convergence.
    find(0, 0, 100) 
  end

  @doc """
  Runs the function find nth time and return the best of the best Knapsack problem solution.

  ## Examples

    iex> Knapsack.run_nth_time(100)

    %Individual{bit_sequence: [1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0,
    0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0], capacity: 11.999999999999998,
    carrying: 12987.0,
    items: [0, 1, 2, 4, 6, 7, 9, 10, 11, 15, 21, 24, 25, 27, 28], price: 4537.0}

  """
  def find_best_result(n) do
    0..n |>
    Enum.map(fn x -> find end) |>
    Enum.sort(&(&1.price > &2.price)) |>
    List.first |> 
    Individual.update_item_indexes
  end

end
