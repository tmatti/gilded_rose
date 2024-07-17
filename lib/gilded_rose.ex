defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  def new() do
    {:ok, agent} =
      Agent.start_link(fn ->
        [
          Item.new("+5 Dexterity Vest", 10, 20),
          Item.new("Aged Brie", 2, 0),
          Item.new("Elixir of the Mongoose", 5, 7),
          Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
          Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
          Item.new("Conjured Mana Cake", 3, 6)
        ]
      end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def update_quality(agent) when is_pid(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item =
        agent
        |> Agent.get(&Enum.at(&1, i))
        |> update_quality()

      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end

  def update_quality(%Item{name: "Aged Brie"} = item) do
    %{item | quality: min(item.quality + 1, 50), sell_in: item.sell_in - 1}
  end

  def update_quality(%Item{name: "Backstage passes to a TAFKAL80ETC concert"} = item) do
    quality_bump =
      cond do
        item.sell_in <= 0 -> item.quality * -1
        item.sell_in <= 5 -> 3
        item.sell_in <= 10 -> 2
        true -> 1
      end

    %{item | quality: item.quality + quality_bump, sell_in: item.sell_in - 1}
  end

  def update_quality(%Item{name: "Sulfuras, Hand of Ragnaros"} = item) do
    %{item | quality: 80}
  end

  def update_quality(item) do
    item =
      if item.quality > 0 do
        %{item | quality: item.quality - 1}
      else
        item
      end

    item = %{item | sell_in: item.sell_in - 1}

    item =
      cond do
        item.sell_in < 0 ->
          cond do
            item.quality > 0 ->
              %{item | quality: item.quality - 1}

            true ->
              item
          end

        true ->
          item
      end

    item
  end
end
