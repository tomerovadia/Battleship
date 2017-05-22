require_relative 'board.rb'
require 'byebug'

class HumanPlayer
    attr_reader = :board
    
    def initialize(board = Board.new)
       @board = board
    end
    
    def get_play(board)
        puts "Where do you want to attack? (Gimme two coordinates)"
        
        begin
            coordinates_array = HumanPlayer.send(:format_user_input,gets.chomp)
            if !(board.in_range?(coordinates_array))
                puts "Coordinates not in range!"
                raise "Coordinates must exist in grid"
            end
            coordinates_array
        rescue
            puts "Try again:"
            retry
        end
    end
    
    private
    
    def self.format_user_input(str)
        coordinates = str.scan(/\d+/)
        
        # Make sure only two coordinates were given
        if coordinates.length != 2
            puts "Give me only two coordinates!" if coordinates.length > 2
            puts "I need two coordinates!" if coordinates.length < 2
            raise "Input must contain two digits"
        end
        
        [coordinates[0].to_i, coordinates[1].to_i]
    end
end