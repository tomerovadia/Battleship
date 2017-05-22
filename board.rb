require 'byebug'

class Board
    attr_accessor :grid
    
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
    
    def in_range?(pos)
        return false if pos[0] >= @grid.length || pos[1] >= @grid[0].length
        true
    end
    
    def won?
        hash_of_positions_and_state.values.all? {|state| state != :s}
    end
    alias :no_ships? :won?
    
    def display
        hidden_ships_grid = map_grid {|state| state == :s ? nil : state}

        # print top column labels
        print_column_labels
        
        # print rows
        hidden_ships_grid.each_with_index do |row, row_num|
            puts ""
            print "#{row_num} "
            row.each {|el| print el ? "[#{el}]" : "[ ]"}
            print " #{row_num}"
        end
        
        # print bottom column labels
        puts ""
        print_column_labels
        puts ""
    end
    
    private
    
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
        print "   "
    end
end