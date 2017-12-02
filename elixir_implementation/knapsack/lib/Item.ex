defmodule Item do
	@moduledoc """
  This is Item module.
  The Item is structure with id, index, carrying, capacity and price.
	"""

	defstruct [:id, :index, :carrying, :capacity, :price] 

	def parse(list) do
	    list |> 
	    Enum.take_every(3) |>
	    Enum.with_index |>
	    Enum.flat_map(fn {{x, i}, k} -> 
	      {cap, _} = Enum.at(list, i + 1)
	      {price, _} = Enum.at(list, i + 2)
	      [%Item{id: k, carrying: x, capacity: cap, price: price}]
	    end)
    end

  def sort_by_price(list) do
  	list |>
    Enum.sort(&(&1.price > &2.price)) |>
   	Enum.with_index |>
   	Enum.map(fn x -> 
   		{item, id} = x
   		%Item{id: item.id, index: id, carrying: item.carrying, capacity: item.capacity, price: item.price} 
   	end)
   end

end