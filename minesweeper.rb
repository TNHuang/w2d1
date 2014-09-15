#! /usr/bin/env ruby
require 'yaml'

class Board

  SIZE = 9

  attr_accessor :tiles

  def initialize(bomb_count = 20)
    @tiles = Array.new(SIZE) {Array.new(SIZE)}
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

  def draw
    disp = Array.new(SIZE) {Array.new(SIZE, ".")}

    SIZE.times do |i|
      SIZE.times do |j|
        disp[i][j] = "F" if self[[i,j]].flagged
        disp[i][j] = "R" if self[[i,j]].revealed

        if self[[i,j]].revealed && self[[i,j]].nearby_bombs > 0
          disp[i][j] = "#{self[[i,j]].nearby_bombs}"
        end

        disp[i][j] = "B" if self[[i,j]].revealed && self[[i,j]].bomb
      end
    end

    puts "# #{(0...SIZE).to_a.join(' ')}"
    disp.each_with_index do |row, index|
      puts "#{index} #{row.join(' ')}"
    end
  end

  protected
  def create_tiles
    SIZE.times do |i|
      SIZE.times do |j|
        self[[i, j]] = Tile.new([i, j], self);
      end
    end

  end

  def seed_bombs
    until @bomb_count.zero?
      pos = [rand(0...SIZE), rand(0...SIZE)]
      next if self[pos].bomb

      self[pos].bomb = true

      @bomb_count -= 1
    end
  end
end

class Tile

  D_NEIGHBORS = [-1, 0, 1].repeated_permutation(2).to_a - [[0, 0]]

  attr_accessor :bomb, :revealed, :pos, :board, :flagged

  def initialize(pos, board, bomb = false)
    @pos, @board, @bomb = pos, board, bomb
    @revealed, @flagged = false, false
  end

  def get_neighbors
    neighbors = []

    D_NEIGHBORS.each do |delta|
      neighbor_pos = [pos[0] + delta[0], pos[1] + delta[1]]
      next unless neighbor_pos.all? {|coord| coord.between?(0, Board::SIZE - 1)}
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
      board.draw

      matches = nil
      while matches.nil?
        response = get_input

        matches = /(r|f)\((\d),(\d)\)/.match(response)
        matches = /s/.match(response) if matches.nil?
      end

      pos = [matches[2].to_i, matches[3].to_i]
      if matches[1] == ?f
        board[pos].flagged = true
      elsif matches[1] == ?r
        board.select_tile(pos)
      else
        save_game
        break
      end

    end

    recap
  end

  def save_game
    p "running"
    File.open('minesweeper_save.yaml', "w") do |f|
      f.write self.to_yaml
    end
  end

  def get_input
    print "flag or reveal a tile, or save game(s)? (eg f(1,2)): "
    gets.strip
  end

  def over?
    won? || lost?
  end

  def won?
    board.tiles.flatten.all? { |tile| tile.revealed ^ tile.bomb }
  end

  def lost?
    board.tiles.flatten.any? { |tile| tile.revealed && tile.bomb }
  end

  def recap
    board.draw
    puts won? ? "Congratulations! You win!" : "BOOM!"
  end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new(20)
  game.play
end
