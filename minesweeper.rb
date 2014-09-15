#! /usr/bin/env ruby

class Board

  attr_accessor :tiles

  def initialize(bomb_count = 10)
    @tiles = Array.new(9) {Array.new(9)}
    @bomb_count = bomb_count
    create_tiles
    seed_bombs
  end

  def select_tile(pos)
    return if self[pos].bomb

    tiles_to_check = [self[pos]]
    until tiles_to_check.empty?
      tile = tiles_to_check.shift
      tile.revealed = true

      tile.get_neighbors.each do |neighbor|
        next if neighbor.revealed
        if tile.nearby_bombs != 0
          next unless neighbor.nearby_bombs.zero?
        end

        tiles_to_check << neighbor
      end
    end
  end

  def [](pos)
    i, j = pos
    tiles[i][j]
  end

  def []=(pos, value)
    i, j = pos
    tiles[i][j] = value
  end

  protected
  def create_tiles
    tiles = []
    9.times do |i|
      9.times do |j|
        self[[i,j]] = Tile.new([i,j], self);
      end
    end

  end

  def seed_bombs
    until @bomb_count.zero?
      i, j = rand(0...@tiles.count), rand(0...@tiles.count)
      next if self.tiles[i][j].bomb

      self.tiles[i][j].bomb = true

      @bomb_count -= 1
    end
  end

  #display method


end

class Tile

  D_NEIGHBORS = [-1, 0, 1].repeated_permutation(2).to_a - [[0, 0]]

  attr_accessor :bomb, :revealed, :pos, :board

  def initialize(pos, board, bomb = false)
    @board, @bomb, @revealed = board, bomb, false
    @pos = pos
  end

  def get_neighbors
    neighbors = []

    D_NEIGHBORS.each do |delta|

      neighbor_pos = [pos[0]+delta[0], pos[1]+delta[1]]

      next unless neighbor_pos.all? {|coord| coord.between?(0,8)}
      neighbors << board[neighbor_pos]
    end

    neighbors
  end

  def nearby_bombs
    get_neighbors.select {|neighbor| neighbor.bomb }.count
  end
end

class Game
end

class Player
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  # puts b[[0,0]].nearby_bombs


  disp = Array.new(9) {Array.new(9, "*")}

  # 9.times do |i|
  #   9.times do |j|
  #     disp[i][j] = b[[i,j]].nearby_bombs unless b[[i,j]].nearby_bombs.zero?
  #   end
  # end
  # #
  # disp.each do |row|
  #   print row.join
  #   puts ''
  # end

end
