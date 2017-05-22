require_relative 'player.rb'
require_relative 'board.rb'

class BattleshipGame
    attr_reader :board, :player

    def initialize(player, board)
        @player = player
        @board = board
    end

    def attack(pos)
        @board.grid[pos[0]][pos[1]] = @board.grid[pos[0]][pos[1]] == :s || @board.grid[pos[0]][pos[1]] == :R ? :R : :x
    end

    def count
       @board.count
    end

    def game_over?
       @board.won?
    end

    def display_status
        @board.display

        puts "There are #{@board.count} ships remaining."
    end

    def play_turn
        coordinates_to_attack = @player.get_play(@board)
        case @board[coordinates_to_attack]
        when :s
            verdict = "YOU BOMBED A SHIP!"
        when :R
            verdict = "You already bombed that spot!"
        when :x
            verdict = "You bombed the same water... again. You okay?"
        else
            verdict = "You bombed the water."
        end
        attack(coordinates_to_attack)
        verdict
    end

    def play
        puts "Welcome to BATTLESHIP!"
        @board.populate_grid
        @board.display
        turns = 0
        until @board.won?
            turns += 1
            verdict = play_turn
            puts "-----------------------------------------------------------------------------"
            display_status
            puts verdict
            puts turns > 1 ? "You've taken #{turns} turns." : "You've taken #{turns} turn."
        end
        puts turns > 1 ? "YOU WON! You took #{turns} turns." : "YOU WON! You took #{turns} turn."
    end
end

if __FILE__ == $PROGRAM_NAME
  BattleshipGame.new(HumanPlayer.new, Board.new).play
end