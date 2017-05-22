require_relative 'improved_player.rb'
require_relative 'improved_board.rb'
require_relative 'improved_ship.rb'


class BattleshipGame
    attr_reader :board, :current_player, :other_player, :player_one, :player_two

    def initialize(player_one = HumanPlayer.new, player_two = HumanPlayer.new)
        @current_player, @player_one = player_one, player_one
        @other_player, @player_two = player_two, player_two
        @player_one.game, @player_two.game = self, self
    end

    def attack(pos, player)
        player.board.grid[pos[0]][pos[1]] = player.board.grid[pos[0]][pos[1]] == :s || player.board.grid[pos[0]][pos[1]] == :R ? :R : :x
    end

    def count
       @current_player.board.count
    end

    def game_over?
       @player_one.no_ships? || @player_two.no_ships?
    end

    def display_status
        puts "\n#{@other_player.name.upcase}'S BOARD:"
        @other_player.board.display(true)

        puts "\n#{@current_player.name.upcase}'S BOARD:"
        @current_player.board.display(false)

        puts "There are #{@current_player.ships.count} ships remaining on your board."
        puts "There are #{@other_player.ships.count} ships remaining on #{other_player.name}'s board."
    end

    def ask_if_ready
        puts "#{@current_player.name}, are you ready? Press ENTER if so."
        @current_player.ready?
    end

    def congratulate_winner
        if @current_player.no_ships?
            puts "#{@other_player.name.upcase} WINS!!! Sorry, #{@current_player.name} :("
        else @other_player.no_ships?
            puts "#{@current_player.name.upcase} WINS!!! Sorry, #{@other_player.name} :("
        end
    end

    def switch_players
        @current_player, @other_player = @other_player, @current_player
        push_screen_up
    end

    def push_screen_up
        45.times {puts ""}
    end

    def get_attack_verdict(coordinates_to_attack)
        case @other_player.board[coordinates_to_attack]
        when :s
            verdict = "YOU BOMBED A SHIP! R is for rubble."
        when :R
            verdict = "You already bombed that spot!"
        when :x
            verdict = "You bombed the same water... again. You okay?"
        else
            verdict = "You bombed the water. x is for dead whales."
        end
        verdict
    end

    def play_turn
        ask_if_ready

        puts "-----------------------------------------------------------------------------"
        puts "#{@current_player.name.upcase}'S TURN:\n"
        puts "-----------------------------------------------------------------------------"
        display_status
        puts "-----------------------------------------------------------------------------"

        coordinates_to_attack = @current_player.get_play(@current_player.board)
        puts get_attack_verdict(coordinates_to_attack)
        attack(coordinates_to_attack, @other_player)
        @other_player.update_ships
        @other_player.board.display(true)


        puts "Press ENTER to erase the screen and end your turn."
        @current_player.end_turn
        switch_players
        puts "#{@other_player.name} bombed #{coordinates_to_attack} which is now #{@current_player.board.grid[coordinates_to_attack[0]][coordinates_to_attack[1]]}."
    end

    def play
        puts "Welcome to BATTLESHIP!"

        puts "Let's start with Player 1"
        @player_one.set_name
        @player_one.set_color

        @player_one.place_all_ships()

        push_screen_up

        puts "Player 2, hit Enter when you're ready."
        @player_two.ready?

        @player_two.set_name
        @player_two.set_color

        @player_two.place_all_ships()

        push_screen_up

        puts "#{@player_one.name.upcase} VS #{@player_two.name.upcase}! Let's do this!\n\n"

        puts "Instructions: \n >>You will take turns. \n >>When it's your turn, I will show you your board as well as that of your opponent. \n >>Your board will show ships. Your opponent's wont. Both will show where attacks have occurred and whether they were successful. \n >>Don't look at the screen when it's not your turn. I will warn you before turns change, so you can trade spots."

        puts "Press ENTER to continue."
        gets




        turns = 0
        until game_over?
            turns += 1
            play_turn
        end
        congratulate_winner
    end
end

if __FILE__ == $PROGRAM_NAME
    BattleshipGame.new(HumanPlayer.new,ComputerPlayer.new).play
end
