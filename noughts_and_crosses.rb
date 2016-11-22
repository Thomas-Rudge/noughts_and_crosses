WINNING_GAMES = [[7, 8, 9], [4, 5, 6], [1, 2, 3], # Horizontal
                 [1, 4, 7], [2, 5, 8], [3, 6, 9], # Vertical
                 [1, 5, 9], [3, 5, 7]]            # Diagonal

class Game
  private :get_players, :get_char_pref, :get_starter, :set_players
  attribute_reader :scores
  attribute_accessor :options
  
  def initialize
    @affirmative = ['y', 'yes', 'yep', 'sure', 'ok', 'okay']
    @scores      = Hash.new
    @options     = {mode: 0, turn: 0, charset: [:X, :O]}
  end
  
  def start
    puts "Would you like to play a game?"
    print "\t>>"
    response = gets.chomp.downcase.gsub(' ', '')
    
    if @affirmative.include? response
      setup()
      board = Board.new(self)
      board.play
    else
      finish()
    end
  end
  
  def replay?
    puts "Would you like to play again?"
    print ">>"
    response = get.chomp.downcase.gsub(' ', '')
    
    @affirmative.include? response
  end
  
  def setup
    get_players()
    set_players()
    get_char_pref()
    get_starter()
    
  end
  
  def get_scoreboard
    max_name_length = @scores.keys.max { |a, b| a.length <=> b.length }.length + 1
    
    puts "\n#{' ' * max_name_length} : Score"
    
    @scores.each do |player, score|
      puts "#{player.ljust(max_name_length)} : #{score}"
    
    case
      when @scores.values.inject(:+) == 0
        puts "\n\t~ Draw ~"
      when @scores[@scores.keys[0]] > @scores[@scores.keys[1]]
        puts "#{@scores.values[0]} is the WINNER!!"
      when @scores[@scores.keys[0]] > @scores[@scores.keys[1]]
        puts "#{@scores.values[1]} is the WINNER!!"
    end
  end
  
  def get_players
    begin
      puts "How many players?"
      print "\t>>"
      response = gets.chomp
      
      unless ["0", "1", "2"].include? response
        raise StandardError
      end
      
    rescue StandardError
      puts "This game supports 0 to 2 players"
      retry
    else
      @options[:mode] = response.to_i
    end
  end
  
  def get_char_pref
    unless @options[:mode] == 0
      puts "What character set should we use?"
      print "\t>>"
      response = get.chomp.to_s[0, 2]
    else
      response = "XO"
      
    @options[:char] = response.length < 2 ? "XO" : [response[0], response[1]]
  end
  
  def get_starter
    unless @options[:mode] == 0
      puts "Do you want to go first?"
      print "\t>>"
      response = gets.chomp.downcase.gsub(' ', '')
    else
      response = 0
      
    @affirmative.include? response ? @options[:turn] = 0 : @options[:turn] = 1
  end
  
  def set_players
    case @options[:mode]
    when 0 then @scores[:Robot1]  = @scores [:Robot2]  = 0
    when 1 then @scored[:Player1] = @scores [:Robot1]  = 0
    when 2 then @scored[:Player1] = @scores [:Player2] = 0
    else puts "Error: get players before setting them"
  end
  
  def finish
    @scores.values.inject(:+) != 0 ? get_scoreboard() : nil
    puts "\nGoodbye"
    exit
  end
end

class Board
  def play
  end
  def build
  end
  def turn
  end
end
