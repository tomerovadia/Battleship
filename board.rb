require 'byebug'
require 'colorize'

class Board
    attr_accessor :grid, :color
    
    def self.default_grid
        Array.new(10) {Array.new(10)}
    end
    
    def initialize(grid = Board.default_grid)
       @grid = grid
    end
    
    def [](pos)
       @grid[pos[0]][pos[1]]
    end
    
    def count
        positions_with_ships = hash_of_positions_and_state.values.select {|pos| pos == :s}
        positions_with_ships.length
    end
    
    def empty?(input = nil)
        # if not given an argument, check if the board itself is empty
        if !(input)
            return self.send(:hash_of_positions_and_state).values.all? {|pos| !pos}
        end
        # otherwise, if passed a position, check if it's nil
        !(self[input])
    end
    
    def full?
        return self.send(:hash_of_positions_and_state).values.all? {|pos| pos == :s}
    end
    
    def spot_taken?(coordinates)
        return false if coordinates.empty?
        coordinates.each do |coordinate|
            if grid[coordinate[0]][coordinate[1]] == :s
                puts "ERROR: LOCATION TAKEN!"
                sleep(1)
                return true
            end
        end
        false
    end
    
    def place_ship(pos)
      @grid[pos[0]][pos[1]] = :s
    end
    
    def place_random_ship
        hash_of_nil_positions = hash_of_positions_and_state.select {|pos,state| !state}
        nil_positions = hash_of_nil_positions.keys
        place_ship(nil_positions.sample)
    end
    
    def populate_grid
        10.times do
           place_random_ship 
        end
    end
    
    def coordinates_in_range?(coordinates)
        coordinates.each do |coordinate|
            if !(in_range?(coordinate))
                puts "ERROR: COORDINATE(S) NOT IN RANGE!"
                sleep(1)
                return false 
            end
        end
        return true
    end
    
    def in_range?(pos)
        return false if pos[0] >= @grid.length || pos[0] < 0 || pos[1] >= @grid[0].length || pos[1] < 0
        true
    end

    def display(hidden)
        if hidden
            grid_to_display = map_grid {|state| state == :s ? nil : state}
        else
            grid_to_display = @grid
        end

        # print top column labels
        print_column_labels
        
        # print rows
        grid_to_display.each_with_index do |row, row_num|
            puts ""
            print "#{row_num} "
            row.each do |el| 
                if el == :x
                    print "[#{el}]"
                elsif el
                    print "[#{el}]".send(@color)
                else
                    print "[ ]"
                end
            end
            print " #{row_num}"
        end
        
        # print bottom column labels
        puts ""
        print_column_labels
        puts ""
    end
    
    
    
    
    def coordinates_in_between(first_coordinate,second_coordinate)
        coordinates = []
    
        if first_coordinate[0] != second_coordinate[0] && first_coordinate[1] != second_coordinate[1]
            puts "ERROR: COORDINATES MUST BE IN A LINE!"
            sleep(2)
            return false
        end
    
        # determine which axis (x or y) is in common between the coordinates
        common_axis = first_coordinate[0] == second_coordinate[0] ? 0 : 1
        common_axis_value = first_coordinate[common_axis]
        other_axis = (common_axis - 1).abs
    
        # for the axis that isn't in common, get the smaller and larger values
        smaller_value = [first_coordinate[other_axis],second_coordinate[other_axis]].min
        larger_value = [first_coordinate[other_axis],second_coordinate[other_axis]].max
    
        # go through those values and create new coordinates each step of the way
        smaller_value.upto(larger_value) do |i|
          if common_axis == 0
            coordinates << [common_axis_value,i]
          else
            coordinates << [i,common_axis_value]
          end
        end
    
        coordinates
    end
    
    
    def hash_of_positions_and_state
        hash = {}
        @grid.each_with_index do |row,i|
            row.each_with_index {|state,j| hash[[i,j]] = state}
        end
        hash
    end
    
    def map_grid(&prc)
        new_grid = []
        @grid.each do |row| 
            new_row = []
            row.each {|state| new_row << prc.call(state)}
            new_grid << new_row
        end
        new_grid
    end
    
    def print_column_labels
        print "  "
        @grid[0].each_index do |col_num|
            print " #{col_num} "
        end
    end
end