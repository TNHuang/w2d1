#! /usr/bin/env ruby

class Board

  attr_accessor :tiles

  def initialize(bomb_count = 20)
    @tiles, @bomb_count = create_tiles, bomb_count
    seed_bombs
  end

  def select_tile(pos)
    return if tile[pos].bomb

    tiles_to_check = [tiles[pos]]
    until tiles_to_check.empty?
      tile = tiles_to_check.shift
      tiles[pos].revealed = true

      # if tile.next_to_bomb?
      #   get neighbors who are not next to bombs
      # else
      #   add all neighbors to tiles_to_check
    end
  end

  def [](pos)
    i, j = pos[0], pos[1]
    tiles[i][j]
  end

  def []=(pos, value)
    i, j = pos[0], pos[1]
    tiles[i][j] = value
  end

  protected
  def create_tiles
    Array.new(9) {Array.new(9) { Tile.new(self) }}
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
  attr_accessor :bomb, :revealed

  def initialize(board, bomb = false)
    @board, @bomb, @revealed = board, bomb, false
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
