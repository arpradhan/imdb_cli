require_relative "omdb.rb"
require_relative "scraper.rb"
require_relative "movie.rb"
require "pry"

class UserInterface
  attr_accessor :scraper, :omdb, :width, :padding
  attr_reader :commands, :command_descriptions

  def initialize
    @scraper = Scraper.new
    @omdb = Omdb.new
    @width = 75;
    @padding = 5;
    @commands = ["help", "opening", "now playing", "coming soon", "search", "exit"]
    @command_descriptions = ["show list of commands", "show movies opening this week",
     "show movies playing this week", "show movies opening next week", "search for a movie title",
     "close application"]
  end

  def call
    welcome
    help
    puts "Please enter a command"
    command = gets.strip
    while command != "exit"
      case command
      when "help"
        help
      when "opening"
        opening
      when "now playing"
        now_playing
      when "coming soon"
        coming_soon
      when "search"
        search
      else
        invalid
      end
      puts "Please enter a command"      
      command = gets.strip
    end
    puts "Goodbye!"
  end

  def welcome
    print_heading("Welcome to IMDB CLI!", "#")
  end

  def help
    print_heading("List of Commands", " ")
    commands.each.with_index do |command, i|
      print_list_item(" " * padding + commands[i] + " ", " " + command_descriptions[i], ". ")
    end
  end

  def opening
    print_heading("Movies opening this week", "+")
    titles = @scraper.opening
    print_titles(titles)
  end

  def now_playing
    print_heading("Movies playing this week", "+")     
    titles = @scraper.now_playing
    print_titles(titles)
  end

  def coming_soon
    print_heading("Movies opening next week", "+") 
    titles = @scraper.coming_soon
    print_titles(titles)   
  end

  def search
    puts "Enter the name of the movie you want to look up"
    command = gets.strip
    print_search_results(command)

    puts "Enter the number of the movie you want read about"
    command = gets.strip  
    movie = @omdb.look_up(command)
    print_profile(movie)
    # movie.print_attributes
    puts "Enter 'trailer' to watch trailer, 'tomatoes' for Rotten Tomatoes data, or 'back' to leave Search"
    command = gets.strip
    while command != "back"
      case command
        when "trailer"  
          movie.youtube
        when "tomatoes"
          movie.tomatoes.print_attributes
      end
      puts "Enter 'trailer' to watch trailer, 'tomatoes' for Rotten Tomatoes data, or 'back' to leave Search"
      command = gets.strip
    end
    help
  end

  def invalid
    puts "That is not a valid command. Please try again"
  end

  def print_profile(movie)
    print_divider("-") 
    puts " " * padding + movie.title + "\n\n"
    puts " " * padding +  "Year: #{movie.year}"
    puts " " * padding +  "Run Time: #{movie.runtime}"
    puts " " * padding +  "Genre(s): #{movie.genre}"
    puts " " * padding +  "IMDB Rating: #{movie.imdb_rating}"  
    print_divider("-") 
    puts parse_plot(movie.plot, padding)
    print_divider("-")
  end

  def print_search_results(command)
    @omdb.search(command)
    @omdb.movies.each do |id, movie|
      puts " " * padding + "#{id}: #{movie.title} (#{movie.year})"
      print_divider("-")
    end     
  end  

  def print_list_item(label, item="", char=" ")
    if item != "" 
      puts (label.ljust(0.5 * width, char) + " " + item )  
    else
      puts " " * padding + label.ljust(0.5 * width)
      puts " " * padding + "-" * width
    end   
  end

  def print_titles(titles)
    titles.each.with_index do |title, i|
      print_list_item("#{i+1}. " + title)
    end     
  end

  def print_heading(message, char="#")
    print_divider(char+" ")
    puts " " * padding + char + " " * (width-2) + char
    puts " " * padding + char + message.center(width-2) + char
    puts " " * padding + char + " " * (width-2) + char   
    print_divider(char+" ") 
    puts ""   
  end  

  def print_divider(char="#")  
    puts " " * padding + char.ljust(width, char)
  end  

  def parse_plot(plot, padding)
    plot = " " * padding + plot
    line_width = width
    line_count = plot.length / width
    line_index = plot.length / line_count
    line_count.times do |i| 
      plot.insert(line_width * (i+1), "\n" + " " * padding)
    end
    plot
  end
end