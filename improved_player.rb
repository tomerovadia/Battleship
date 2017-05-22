require_relative 'improved_board.rb'
require_relative 'improved_ship.rb'
require 'byebug'
require 'colorize'

class Player
    attr_reader :board
    attr_accessor :name, :ships, :game
    
    def initialize(board = Board.new)
        @board = board
        @ships = []
    end

    def update_ships
        @ships = @ships.select do |ship|
            !(ship.sunk?)
        end
    end
    
    def create_ship(first_end, second_end, ship_type, ship_size)
        new_ship =  Ship.new(self,first_end, second_end)
        @ships << new_ship
        new_ship.christen(@board)
    end
    
    
    def no_ships?
        @ships.empty?
    end
    
end




class HumanPlayer < Player
    
    def ready?
        gets
        true
    end
    
    def end_turn
        gets
    end
    
    def set_name
        puts "What's your name?"
        @name = gets.chomp
    end
    
    def set_color
        puts "#{@name}, what color do you want to be?:"
        print "Options: "
        String.colors.each {|color| print color.to_s + " "}
        puts
        selected_color = gets.chomp.downcase
        until String.colors.include?(selected_color.to_sym)
             puts "Please select a valid color."
             selected_color = gets.chomp.downcase
        end
        @board.color = selected_color
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
    
    
    def get_ship(ship_type, target_size)
        puts "\n#{@name}, let's place your #{ship_type} (#{target_size}x1)."
        
        begin
            puts "Enter coordinates for the first end of your #{ship_type}."
            first_end = HumanPlayer.send(:format_user_input,gets.chomp)
        rescue
            sleep(2)
            puts "Try again:"
            retry
        end
        
        begin
            puts "Enter coordinates for the other end of your #{ship_type}."
            second_end = HumanPlayer.send(:format_user_input,gets.chomp)
        rescue
            sleep(2)
            puts "Try again:"
        end
        
        [first_end, second_end]
    end
    
    def place_ship(ship_type)
        target_size = Ship::SHIPS[ship_type]
        ends = get_ship(ship_type, target_size)
        first_end,second_end = *ends
        coordinates = @board.coordinates_in_between(first_end,second_end)

        until coordinates && @board.coordinates_in_range?(coordinates) && !(@board.spot_taken?(coordinates)) && ship_size_ok?(target_size, coordinates)
            ends = get_ship(ship_type,target_size)
            first_end, second_end = *ends
            coordinates = @board.coordinates_in_between(first_end,second_end)
        end
        
        create_ship(first_end, second_end, ship_type, coordinates.length)
    end
    

    def place_all_ships
        Ship::SHIPS.keys.each do |ship_type|
            place_ship(ship_type)
            @board.display(false)
        end
        puts "\n"
        
    end
    
    def ship_size_ok?(ship_size, coordinates)
        if ship_size != coordinates.length
            puts "\nERROR: NEED A #{ship_size}x1 SHIP!"
            sleep(2)
            return false
        end
        true
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





class ComputerPlayer < Player
    
    def ready?
       true 
    end
    
    
    def end_turn
        # intentionally blank
    end
    
    
    def set_name
        puts "What's your name?"
        puts "Barack Obama"
        @name = "Barack Obama"
    end
    
    
    def set_color
        puts "#{@name}, what color do you want to be?:"
        print "Options: "
        String.colors.each {|color| print color.to_s + " "}
        puts
        puts "red"
        @board.color = "red"
    end
    
    
    def get_play(board)
        hash_of_possible_positions = @game.other_player.board.hash_of_positions_and_state.select {|pos,state| !state || state == :s}
        random_possible_position = hash_of_possible_positions.keys.sample
        random_possible_position
    end
    
    
    def get_ship(ship_type, target_size)
        coordinates = []
        
        # until we get coordinates that are all in range and aren't taken
        until !(coordinates.empty?) && coordinates.all? {|coordinate| @board.in_range?(coordinate)} && !(@board.spot_taken?(coordinates))
            start_end_coordinates = []
            
            # get a random nil position
            hash_of_nil_positions = @board.hash_of_positions_and_state.select {|pos,state| !state}
            nil_positions = hash_of_nil_positions.keys
            start_coordinate = nil_positions.sample
            
            start_end_coordinates << start_coordinate
            
            end_coordinate = [start_coordinate[0],start_coordinate[1]]
            inc_or_dec = rand(2)
            if inc_or_dec == 1
                end_coordinate[rand(2)] += target_size-1
            else
                end_coordinate[rand(2)] -= target_size-1
            end
            start_end_coordinates << end_coordinate
            
            coordinates = @board.coordinates_in_between(start_coordinate,end_coordinate)
        end
        
        start_end_coordinates
    end
    
    
    def place_ship(ship_type)
        target_size = Ship::SHIPS[ship_type]
        ends = get_ship(ship_type, target_size)
        new_ship =  Ship.new(self,ends[0], ends[1])
        @ships << new_ship
        new_ship.christen(@board)
    end
    
    
    
    def place_all_ships
        Ship::SHIPS.keys.each do |ship_type|
            place_ship(ship_type)
        end
        @board.display(false)
        puts "\n"
    end
    
end