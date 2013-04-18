$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require 'mirimiri'
require "benchmark"

# Fetch the text content of two Wikipedia pages using their URLs
w = Mirimiri::WikipediaPage.new("http://en.wikipedia.org/wiki/The_Dillinger_Escape_Plan")
u = Mirimiri::WikipediaPage.new("http://en.wikipedia.org/wiki/Pantera")

# Compute the entropy of a word sequence, using `w` as context
p w.entropy("dillinger escape plan")
p w.tf("guitar")

# Compute the KL-Divergence between the two pages
p w.kl u


# Mirimiri also comprises Indri-related classes

# Building an Indri query
query = Indri::IndriQuery.new({:query => "dillinger escape plan".sequential_dependence_model, :count => 10}, "-trecFormat=true -printDocuments=true")

# Initializing the index on which the query will be executed
# Must have been previously built using `IndriBuildIndex`
index = Indri::IndriIndex.new "/mnt/disk1/ClueWeb09_English_1noSpam"

# Run the query on the index and fetch the text of the documents
s = Indri::IndriPrintedDocuments.new(index.runquery(query).force_encoding("ISO-8859-1").encode("UTF-8"))
