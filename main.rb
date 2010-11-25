$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require 'rir'

w = RIR::WikipediaPage.new("http://en.wikipedia.org/wiki/The_Dillinger_Escape_Plan")
p w.entropy("dillinger escape plan")
p w.tf("guitar")
