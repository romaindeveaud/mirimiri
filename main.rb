$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require 'mirimiri'

w = Mirimiri::WikipediaPage.new("http://en.wikipedia.org/wiki/The_Dillinger_Escape_Plan")
p w.entropy("dillinger escape plan")
p w.tf("guitar")

query = Indri::IndriQuery.new({:query => "dillinger escape plan".sequential_dependence_model, :count => 10}, "-trecFormat=true -printDocuments=true")
index = Indri::IndriIndex.new "/mnt/disk1/ClueWeb09_English_1noSpam"
s = Indri::IndriPrintedDocuments.new(index.runquery(query).force_encoding("ISO-8859-1").encode("UTF-8"))
