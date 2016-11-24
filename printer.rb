module Printer
  def special_print(movement, output, colour, *args)
    prefix = args.empty? ? "" : args[0]
    colour = "" unless colour
    movement.times { print "\033[A"}
    print "\033[K"
    print "#{prefix}#{colour}#{output}\e[0m"
  end
  
  def clear_screen
    RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i ? system("cls") : system("clear")
  end
end
