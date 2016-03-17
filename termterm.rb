#!/usr/bin/env ruby

require "awesome_print" 
require "part_of_speech"

#dictfile = "/usr/share/dict/words"
@numTerms = 20

# Picks a random word
def randWord 
  chosen = nil
  File.foreach("/usr/share/dict/words").each_with_index do |line,number|
    chosen = line if rand < 1.0/(number+1) 
  end
  return chosen
end

# Makes sure we've got a good word - proper length, no funny characters, and the right part of speech
def validate( word, order )
  if( word !~ /^[a-z]+$/ ) # Ensure our word is only lowercase a-z, no uppercase (proper nouns), no special characters
    return false
  elsif( word.length < 5 || word.length > 9 ) # Long words only!
    return false
  else
  
    out = PartOfSpeech.analyze( "/home/barrettj/Old/gitrepos/scripts/lexicon.txt", word )
    if( out[0][1] =~ /NN/ && order == 2 ) # Noun is good in either position
      return true
    elsif( out[0][1] == "JJ" && order == 1 ) # Adjective is good for position 1
      return true
    elsif( out[0][1] =~ /^VB/ && order == 1 ) # Verb is good for position 1
      return true
    else
      # Part of speech we don't want
      return true # TEMP
    end
  end
end

def goodPhrase
  one = two = false
  wordOne = wordTwo = nil
#  len = 0

  while( one == false )
    wordOne = randWord.chomp
    one = validate( wordOne, 1 )
  end

  while( two == false )
    wordTwo = randWord.chomp
    two = validate( wordTwo, 2 )
  end
  if( wordOne.length + wordTwo.length > 15 )
    goodPhrase
  else
    phrase = "#{wordOne} #{wordTwo}"
    return phrase
  end
end

(1..@numTerms).each do |i|
  print "#{i} #{goodPhrase.to_s}\n"
end
