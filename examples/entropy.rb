require 'rir'

# Concatenates all lines from one file, without \n
readme = File.open('README.markdown').readlines.collect { |l| l.chomp }.join(" ")

# Creates the document with a string
doc = RIR::Document.new readme

# Outputs all the unique words of the document with their entropy scores
p doc.words.collect { |w| "#{w} => #{doc.entropy w}" }
