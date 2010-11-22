$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require 'rir'

w = RIR::WikipediaPage.new("http://en.wikipedia.org/wiki/The_Dillinger_Escape_Plan")
p w.entropy("guitar")

params = RIR::Indri::Parameters.new("path_vers_mon_index")
q = RIR::Indri::IndriQuery.new("pouet", "bla", params)
puts q

c = RIR::Corpus.new "/home/romain/INEX/BookTrack/corpus/"
puts c.files.size
