#! /usr/bin/env ruby

class Board

  attr_accessor :tiles

  def self.create_tiles
    Array.new(9) {Array.new(9) { Tile.new }}
  end

  def initialize(bomb_count = 20)
    @tiles, @bomb_count = Board.create_tiles, bomb_count
    seed_bombs
  end

  def seed_bombs
    until @bomb_count.zero?
      i, j = rand(0...@tiles.count), rand(0...@tiles.count)
      next if self.tiles[i][j].bomb

      self.tiles[i][j].bomb = true

      @bomb_count -= 1
    end
  end

end

class Tile
  attr_accessor :bomb

  def initialize(bomb = false)
    @bomb = bomb
  end

end

class Game
end

class Player
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  puts b.tiles
end
