require 'byebug'
require 'set'

class WordChainer

  attr_reader :dictionary_file, :current_words, :all_seen_words

  def initialize
    @dictionary_file = File.new('./dictionary.txt')
    @dictionary = nil
    @current_words = nil
    @all_seen_words = nil
    @path = []
  end

  ####################################
  # LOAD DICTIONARY FILE & CREATE DICTIONARY SET
  ####################################

  def convert_dictionary_file_to_set
    @dictionary = @dictionary_file.readlines.map(&:chomp).to_set
  end

  def print_dictionary_set
    print @dictionary
  end

  ####################################
  # FIND ADJACENT WORDS
  ####################################

  # cat => [rat, bat, mat, sat, tat....] => find for every letter substituted at each index

  def find_adjacent_words(word)
    alphabet = ('a'..'z').to_a
    all_adjacent_words = []

    word.each_char.with_index do |char, i|
      alphabet.each do |alpha_letter|
        dup_word = word.dup
        dup_word[i] = alpha_letter
        all_adjacent_words << dup_word if @dictionary.include?(dup_word)
      end
    end

    all_adjacent_words.uniq    
  end

  ####################################
  # FIND ALL WORDS FROM SOURCE [BFS]
  ####################################

  # source_word = 'buy'

  def run(source_word, target_word)
    @current_words = [source_word]
    @all_seen_words = {source_word => nil}

    until @current_words.empty?
      explore_current_words(@current_words)
      break if @all_seen_words.has_key?(target_word)
    end
    
    build_path(target_word).include?(source_word) ? @path : nil
    
  end


  def explore_current_words(current_words)
    new_current_words = []
    
    @current_words.each do |current_word|
        adjacent_words_of_current_word = find_adjacent_words(current_word)

        adjacent_words_of_current_word.each do |adjacent_word|
          if !@all_seen_words.include?(adjacent_word)
            @all_seen_words[adjacent_word] = current_word    
            new_current_words << adjacent_word
          end
        end

        @current_words = new_current_words
      end
  end


  ####################################
  # BUILD PATH FROM SOURCE TO TARGET
  ####################################

  def build_path(target_word)
    # debugger
    source_to_target_path = [target_word]
    current_word = target_word
    prev_word = @all_seen_words[current_word]

    until prev_word.nil?
      source_to_target_path.unshift(prev_word)
      current_word = prev_word
      prev_word = @all_seen_words[current_word]
    end
    @path = source_to_target_path
    @path
  end
end


wc = WordChainer.new
wc.convert_dictionary_file_to_set
p wc.run('rocket', 'zephyr')
