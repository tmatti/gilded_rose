defmodule ItemTest do
  use ExUnit.Case

  alias GildedRose.Item

  test "creates an item" do
    %Item{} = item = Item.new("test item", 10, 1)
    assert %{name: "test item", sell_in: 10, quality: 1} = item
  end
end
