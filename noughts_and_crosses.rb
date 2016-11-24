BASE_COLOUR  = "\e[1;34m" # Light blue text on black

module Printer

  def special_print(movement, output, colour, *args)
    prefix = args.empty? ? "" : args[0]
    colour = "" unless colour
    movement.times { print "\033[A"}
    print "#{prefix}#{colour}#{output}\e[0m"
  end
end

class Game
  include Printer

  SCORE_COLOUR = "\e[1;32m" # Light green text on black
  WIN_COLOUR   = "\e[47m\e[2;31m" # Red text on black

  def initialize
    @affirmative = ["y", "yes", "yep", "sure", "ok", "okay"]
    @scores      = Hash.new
    @options     = {mode: 0, turn: 0, charset: [:X, :O], ai: 2}
  end

  def start
    special_print(0, "Would you like to play a game?\n", BASE_COLOUR)
    special_print(0, ">>", BASE_COLOUR, "\t")
    response = gets.chomp.downcase.gsub(" ", "")

    if @affirmative.include? response
      setup
      clear_screen
      go_to_board
    else
      finish
    end
  end

  def go_to_board
    board = Board.new(self)
    winner = board.play

    @scores[winner] += 1 unless winner.eql? false

    get_scoreboard

    replay?
  end

  def replay?
    special_print(0, "Would you like to play again?\n", BASE_COLOUR)
    special_print(0, ">>", BASE_COLOUR, "\t")
    response = gets.chomp.downcase.gsub(" ", "")

    (@affirmative.include? response) ? (clear_screen; go_to_board) : finish
  end

  def setup
    get_players
    set_players
    get_starter
  end

  def clear_screen
    RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i ? system("cls") : system("clear")
  end

  def get_scoreboard
    max_name_length = @scores.keys.max { |a, b| a.length <=> b.length }.length

    special_print(0, "#{" " * max_name_length} : Score\n", SCORE_COLOUR, "\n")

    @scores.each do |player, score|
      special_print(0, "#{player.to_s.ljust(max_name_length)} : #{score}\n", SCORE_COLOUR)
    end

    unless @scores.values.inject(:+) == 0
      case
      when @scores[@scores.keys[0]] == @scores[@scores.keys[1]]
        special_print(0, "~ Draw ~\n\n", WIN_COLOUR, "\n\t")
      when @scores[@scores.keys[0]] > @scores[@scores.keys[1]]
        special_print(0, "#{@scores.keys[0]} is winning!\n\n", WIN_COLOUR, "\n\t")
      when @scores[@scores.keys[0]] < @scores[@scores.keys[1]]
        special_print(0, "#{@scores.keys[1]} is winning!\n\n", WIN_COLOUR, "\n\t")
      end
    end
  end

  def get_players
    begin
      special_print(0, "How many players?\n", BASE_COLOUR)
      special_print(0, ">>", BASE_COLOUR, "\t")
      response = gets.chomp

      unless ["0", "1", "2"].include? response
        raise StandardError
      end

    rescue StandardError
      special_print(0, "This game supports 0 to 2 players\n", WIN_COLOUR)
      retry
    else
      @options[:mode] = response.to_i
    end
  end

  def get_starter
    case @options[:mode]
    when 0
      response = "y"
    when 1
      special_print(0, "Do you want to go first?\n", BASE_COLOUR)
      special_print(0, ">>", BASE_COLOUR, "\t")
      response = gets.chomp.downcase.gsub(" ", "")
    when 2
      special_print(0, "Which player is going first?\n", BASE_COLOUR)
      special_print(0, ">>", BASE_COLOUR, "\t")
      response = gets.chomp.scan(/\d/)

      response = response.empty? ? ["1"] : response
      response = response[0] == "1" ? "y" : "n"
    else
      special_print(0, "Error: bad value for mode:- #{@options[:mode]}!\n", WIN_COLOUR)
    end

    @affirmative.include? response ? @options[:turn] = 0 : @options[:turn] = 1
  end

  def set_players
    case @options[:mode]
    when 0 then @scores[:Robot2]  = @scores [:Robot1]  = 0
    when 1 then @scores[:Robot1]  = @scores [:Player1] = 0
    when 2 then @scores[:Player2] = @scores [:Player1] = 0
    else special_print(0, "Error: get players before setting them\n", WIN_COLOUR)
    end
  end

  def finish
    special_print(0, "Goodbye\n", nil)
    exit
  end

  private :get_players, :get_starter, :set_players, :go_to_board
  attr_reader :scores
  attr_accessor :options
end

class Board
  include Printer

  BOARD_COLOUR = "\e[44m\e[1;32m" # Light blue text on blue

  WINNING_GAMES = [[7, 8, 9], [4, 5, 6], [1, 2, 3], # Horizontal _7_|_8_|_9_
                   [1, 4, 7], [2, 5, 8], [3, 6, 9], # Vertical   _4_|_5_|_6_
                   [1, 5, 9], [3, 5, 7]]            # Diagonal    1 | 2 | 3

  CLOSE_WINS = {[1, 2]=>3, [2, 3]=>1, [4, 5]=>6, [5, 6]=>4, [7, 8]=>9, # Horizontal
                [8, 9]=>7, [1, 3]=>2, [4, 6]=>5, [7, 9]=>8,
                [1, 4]=>7, [4, 7]=>1, [2, 5]=>8, [5, 8]=>2, [3, 6]=>9, # Vertical
                [6, 9]=>3, [1, 7]=>4, [2, 8]=>5, [3, 9]=>6,
                [1, 5]=>9, [5, 9]=>1, [3, 5]=>7, [5, 7]=>3,            # Diagonal
                [1, 9]=>5, [3, 7]=>5}

  def initialize(game)
    @game = game
    @status = Hash.new

    @game.scores.keys.each { |player| @status[player] = [] }
  end

  def play
    view = build
    create(view)
    state = false

    while true
      state = check_status()
      if state.nil?
        while true
          this_turn = turn
          break if this_turn
        end
        @game.options[:turn]  ^= 1

        view = build
        create(view)
      else
        break
      end
    end

    state
  end

  def build
    users_char = Hash.new
    [0, 1].each { |i| users_char[@game.scores.keys[i]] = @game.options[:charset][i] }

    moves = Array.new(9)

    @status.each do |player, player_moves|
      (1..9).each do |i|
        moves[i-1] = (player_moves.include? i) ? users_char[player] : moves[i-1]
      end
    end

    moves.map! { |x| x ? x : " " }

    moves
  end

  def create(moves)
    top    = "   |   |   \n"
    bottom = "___|___|___\n"

    special_print(11, top, BOARD_COLOUR, "\t")
    special_print(0, " #{moves[6]} | #{moves[7]} | #{moves[8]} \n", BOARD_COLOUR, "\t")
    special_print(0, bottom, BOARD_COLOUR, "\t")
    special_print(0, top, BOARD_COLOUR, "\t")
    special_print(0, " #{moves[3]} | #{moves[4]} | #{moves[5]} \n", BOARD_COLOUR, "\t")
    special_print(0, bottom, BOARD_COLOUR, "\t")
    special_print(0, top, BOARD_COLOUR, "\t")
    special_print(0, " #{moves[0]} | #{moves[1]} | #{moves[2]} \n", BOARD_COLOUR, "\t")
    special_print(0, top, BOARD_COLOUR, "\t")
  end

  def get_robot_move
    sleep 1
    valid_moves = (1..9).to_a - @status.values.flatten

    apponent = @status.keys[@game.options[:turn]^1]
    apponent_moves = @status[apponent].length > 1 ? @status[apponent].permutation(2).to_a : @status[apponent]

    move = valid_moves.sample

    if [false, [true]*@game.options[:ai]].flatten.sample
      apponent_moves.each do |p|
        if (CLOSE_WINS.keys.include? p) && (valid_moves.include? CLOSE_WINS[p])
          move = CLOSE_WINS[p]
          break
        end
      end
    end

    move
  end

  def get_player_move
    special_print(0, ">>", BASE_COLOUR, "\t")
    move = gets.chomp.to_i

    unless ((1..9).include? move) && !(@status.values.flatten.include? move)
      special_print(0, "Invalid move #{move}!\n", BASE_COLOUR)
      move = false
    end

    move
  end

  def turn
    success = true
    current_player = @status.keys[@game.options[:turn]]
    special_print(0, "#{current_player} next move~\n", BASE_COLOUR)
    case @game.options[:mode]
    when 0
      @status[current_player] << get_robot_move
    when 1
      if current_player.to_s.include? "Robot"
        @status[current_player] << get_robot_move
      else
        move = get_player_move
        if move
          @status[current_player] << move
        else
           success = false
        end
      end
    when 2
      move = get_player_move
      if move
        @status[current_player] << move
      else
         success = false
      end
    end

    success
  end

  def check_status
    winner = nil

    @status.keys.each do |player|
      moves = @status[player].sort
      moves = moves.product(moves).product(moves).map { |i| i.flatten.sort }
      moves.each { |move| winner = player if WINNING_GAMES.include? move }

      break unless winner.nil?
    end

    winner = (winner.nil? && @status.values.flatten.sort == (1..9).to_a) ? false : winner

    winner
  end

  attr_reader :status
end

