defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  alias GildedRose.Item

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  test "quality and sell_in degrade each day" do
    {:ok, gilded_rose} =
      Agent.start_link(fn ->
        [
          Item.new("test", 10, 10)
        ]
      end)

    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%Item{sell_in: 9, quality: 9}] = Agent.get(gilded_rose, & &1)
  end

  test "quality degrades twice as fast when sell_in is less than 0" do
    {:ok, gilded_rose} =
      Agent.start_link(fn ->
        [
          Item.new("test", -1, 10)
        ]
      end)

    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%Item{quality: 8}] = Agent.get(gilded_rose, & &1)
  end

  test "aged brie increases in quality as sell_in decreases" do
    {:ok, brie} =
      Agent.start_link(fn ->
        [
          Item.new("Aged Brie", 50, 1)
        ]
      end)

    assert :ok == GildedRose.update_quality(brie)
    assert [%Item{sell_in: 49, quality: 2}] = Agent.get(brie, & &1)
  end

  test "quality is never more than 50" do
    {:ok, brie} =
      Agent.start_link(fn ->
        [
          Item.new("Aged Brie", 1, 50)
        ]
      end)

    assert :ok == GildedRose.update_quality(brie)
    assert [%Item{sell_in: 0, quality: 50}] = Agent.get(brie, & &1)
  end

  test "quality is never less than 0" do
    {:ok, gilded_rose} =
      Agent.start_link(fn ->
        [
          Item.new("test", 1, 0)
        ]
      end)

    assert :ok == GildedRose.update_quality(gilded_rose)
    assert [%Item{sell_in: 0, quality: 0}] = Agent.get(gilded_rose, & &1)
  end

  test "sulfras do not decrease in quality" do
    {:ok, sulfuras} =
      Agent.start_link(fn ->
        [
          Item.new("Sulfuras, Hand of Ragnaros", 1, 80)
        ]
      end)

    assert :ok == GildedRose.update_quality(sulfuras)
    assert [%Item{sell_in: 1, quality: 80}] = Agent.get(sulfuras, & &1)
  end

  test "sulfras quality is always reset to 80" do
    {:ok, sulfuras} =
      Agent.start_link(fn ->
        [
          Item.new("Sulfuras, Hand of Ragnaros", 1, 1)
        ]
      end)

    assert :ok == GildedRose.update_quality(sulfuras)
    assert [%Item{sell_in: 1, quality: 80}] = Agent.get(sulfuras, & &1)
  end

  test "backstage passes increase in quality as sell_in decreases" do
    {:ok, backstage_pass} =
      Agent.start_link(fn ->
        [
          Item.new("Backstage passes to a TAFKAL80ETC concert", 11, 0)
        ]
      end)

    assert :ok == GildedRose.update_quality(backstage_pass)
    assert [%Item{sell_in: 10, quality: 1}] = Agent.get(backstage_pass, & &1)
  end

  test "backstage passes cannot increase above 50 quality" do
    {:ok, backstage_pass} =
      Agent.start_link(fn ->
        [
          Item.new("Backstage passes to a TAFKAL80ETC concert", 11, 50)
        ]
      end)

    assert :ok == GildedRose.update_quality(backstage_pass)
    assert [%Item{sell_in: 10, quality: 50}] = Agent.get(backstage_pass, & &1)
  end

  test "backstage passes increase in quality by 2 when sell_in is <= 10" do
    {:ok, backstage_pass} =
      Agent.start_link(fn ->
        [
          Item.new("Backstage passes to a TAFKAL80ETC concert", 10, 0)
        ]
      end)

    assert :ok == GildedRose.update_quality(backstage_pass)
    assert [%Item{sell_in: 9, quality: 2}] = Agent.get(backstage_pass, & &1)
  end

  test "backstage passes increase in quality by 3 when sell_in is <= 5" do
    {:ok, backstage_pass} =
      Agent.start_link(fn ->
        [
          Item.new("Backstage passes to a TAFKAL80ETC concert", 5, 0)
        ]
      end)

    assert :ok == GildedRose.update_quality(backstage_pass)
    assert [%Item{sell_in: 4, quality: 3}] = Agent.get(backstage_pass, & &1)
  end

  test "backstage passes drop to 0 quality when sell_in is <0" do
    {:ok, backstage_pass} =
      Agent.start_link(fn ->
        [
          Item.new("Backstage passes to a TAFKAL80ETC concert", 0, 50)
        ]
      end)

    assert :ok == GildedRose.update_quality(backstage_pass)
    assert [%Item{sell_in: -1, quality: 0}] = Agent.get(backstage_pass, & &1)
  end

  test "conjured items decrease in value twice as fast" do
    {:ok, conjured} =
      Agent.start_link(fn ->
        [
          Item.new("Conjured Mana Cake", 10, 10)
        ]
      end)

    assert :ok == GildedRose.update_quality(conjured)
    assert [%Item{sell_in: 9, quality: 8}] = Agent.get(conjured, & &1)
  end
end
