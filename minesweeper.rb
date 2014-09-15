class Board
  def self.create_tiles
    Array.new(9) {Array.new(9) { Tile.new }}
  end

  def initialize
    @tiles = Board.create_tiles
  end

end

class Tile
end

class Game
end

class Player
end