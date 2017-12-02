defmodule Individual do
	@moduledoc """
  This is Indu module.
  The Individual is structure with bit sequence, items, carrying, capacity and price.
	"""

	defstruct [:bit_sequence, :items, :carrying, :capacity, :price] 

	@doc """
	Counts carrying, capacity and price of individual.
	"""
	def getSequenceInfo(bit_sequence, items) do
  	bit_sequence |> 
  	Enum.with_index |>
  	Enum.filter(fn x -> 
  		{x, _} = x
  		x == 1 
  	end) |>
  	Enum.reduce({0, 0, 0}, fn x, acc -> 
  		{car, cap, price} = acc
  		{x, index} = x
  		item = Enum.at(items, index)
  		{item.carrying + car, item.capacity + cap, item.price + price}
  	end)
  end

  @doc """
  Add in the individual item's indexes from bit sequence.
  """
  def update_item_indexes(individual) do
  	items = individual.bit_sequence |>
  	Enum.with_index |>
  	Enum.filter(fn {x, k} -> x == 1 end) |>
  	Enum.map(fn {x, k} -> k end)
  	%Individual{bit_sequence: individual.bit_sequence,
  		carrying: individual.carrying,
  		capacity: individual.capacity,
  		price: individual.price,
  		items: items}
  end

	def parse(bit_sequence, items, max_carrying, max_capacity) do
		bit_sequence |>
		Enum.map(fn x -> 
			{car, cap, price} = getSequenceInfo(x, items)
			%Individual{bit_sequence: x, 
				carrying: car, 
				capacity: cap, 
				price: (if car > max_carrying || cap > max_capacity, do: 0, else: price) }
		end)
	end
end