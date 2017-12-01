defmodule Item do
	defstruct [:id, :carrying, :capacity, :price] 

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

    def getCarrying(list) do
    	list |> 
    	Enum.reduce(0, fn item, sum -> item.carrying  + sum end)
    end

    def getCapacity(list) do
    	list |> 
    	Enum.reduce(0, fn item, sum -> item.capacity  + sum end)
    end

    def getPrice(list) do
    	list |> 
    	Enum.reduce(0, fn item, sum -> item.price  + sum end)
    end

end