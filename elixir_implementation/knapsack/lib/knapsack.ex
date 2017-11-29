defmodule Knapsack do

  def solve do
    {:ok, data} = File.read "../../38.txt"
    list = Regex.split(~r{( |\n)}, data)
    {carrying, _} = Integer.parse(Enum.at(list, 0))
    carrying
  end

end
