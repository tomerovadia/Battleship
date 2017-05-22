class Ship
    
    attr_accessor :size, :type, :coordinates, :first_end, :second_end, :player, :board, :sunk
    
    SHIPS = {"Aircraft Carrier" => 5,
        "Battleship" => 4,
        "Submarine" => 3,
        "Cruiser" => 3,
        "Destroyer" => 2}
        
    def initialize(player, first_end, second_end)
        @player = player
        @first_end = first_end
        @second_end = second_end
        @coordinates = player.board.coordinates_in_between(first_end,second_end)
        @size =  @coordinates.length
        @type = SHIPS.invert[@coordinates.length]
        @sunk = false
    end
        
    def christen(board)
        @board = board
        coordinates.each {|coordinate| @board.grid[coordinate[0]][coordinate[1]] = :s}
    end
    
    def sunk?
        @sunk = coordinates.all? do |coordinate|
            @board.grid[coordinate[0]][coordinate[1]] != :s
        end
        puts "YOU SUNK MY #{@type.upcase}!" if @sunk
        @sunk
    end
    
end