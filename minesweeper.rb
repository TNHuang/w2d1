#! /usr/bin/env ruby

class Board

  attr_accessor :tiles

  def initialize(bomb_count = 20)
    @tiles = Array.new(9) {Array.new(9)}
    @bomb_count = bomb_count
    create_tiles
    seed_bombs
  end

  def select_tile(pos)

    tiles_to_check = [self[pos]]
    until tiles_to_check.empty?
      tile = tiles_to_check.shift

      tile.revealed = true

      tile.get_neighbors.each do |neighbor|
        next if neighbor.revealed || neighbor.bomb || neighbor.flagged
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

  attr_accessor :bomb, :revealed, :pos, :board, :flagged

  def initialize(pos, board, bomb = false)
    @board, @bomb, @revealed = board, bomb, false
    @pos = pos
    @flagged = false
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

  attr_accessor :board

  def initialize(bombs = 20)
    @board = Board.new(bombs)
  end

  def play
    until over?

      matches = nil

      while matches.nil?
        response = get_input
        matches = /(r|f)\((\d),(\d)\)/.match(response)
      end

      pos = [matches[2].to_i, matches[3].to_i]
      if matches[1] == 'f'
        board[pos].flagged = true
      elsif macthes[1] == 'r'
        board.select_tile(pos)
      end

    end
  end

  def get_input
    print "flag or reveal a tile? (eg f(1,2)): "
    gets.strip
  end

  def over?
    won? || lost?
  end

  def won?
    tile_list = board.tiles.inject([]) { |accum, row| accum + row }
    tile_list.all? { |tile| tile.revealed ^ tile.bomb }
  end

  def lost?
    tile_list = board.tiles.inject([]) { |accum, row| accum + row }
    tile_list.any? { |tile| tile.revealed && tile.bomb }
  end

end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  b.select_tile([1,2])


  disp = Array.new(9) {Array.new(9, ".")}

  9.times do |i|
    9.times do |j|
      disp[i][j] = "R" if b[[i,j]].revealed
      disp[i][j] = "B" if b[[i,j]].revealed && b[[i,j]].bomb

      if b[[i,j]].revealed && b[[i,j]].nearby_bombs > 0
        disp[i][j] = "#{b[[i,j]].nearby_bombs}"
      end

    end
  end
  # #
  disp.each do |row|
    print row.join(' ')
    puts ''
  end

end
