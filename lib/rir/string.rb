#!/usr/bin/env ruby

#--
# This file is a part of an Information Retrieval oriented Ruby library
#
# Copyright (C) 2010-2011 Romain Deveaud <romain.deveaud@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

module RIR

  # These are the default stopwords provided by Lemur.
  Stoplist = [
  "a", "anything", "anyway", "anywhere", "apart", "are", "around", "as", "at", "av",
  "be", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand",
  "behind", "being", "below", "beside", "besides", "between", "beyond", "both", "but", "by",
  "can", "cannot", "canst", "certain", "cf", "choose", "contrariwise", "cos", "could", "cu",
  "day", "do", "does", "doesn't", "doing", "dost", "doth", "double", "down", "dual", "during",
  "each", "either", "else", "elsewhere", "enough", "et", "etc", "even", "ever", "every",
  "everybody", "everyone", "everything", "everywhere", "except", "excepted", "excepting",
  "exception", "exclude", "excluding", "exclusive", "far", "farther", "farthest", "few", "ff",
  "first", "for", "formerly", "forth", "forward", "from", "front", "further", "furthermore",
  "furthest", "get", "go", "had", "halves", "hardly", "has", "hast", "hath", "have", "he",
  "hence", "henceforth", "her", "here", "hereabouts", "hereafter", "hereby", "herein", "hereto",
  "hereupon", "hers", "herself", "him", "himself", "hindmost", "his", "hither", "hitherto",
  "how", "however", "howsoever", "i", "ie", "if", "in", "inasmuch", "inc", "include",
  "included", "including", "indeed", "indoors", "inside", "insomuch", "instead", "into",
  "inward", "inwards", "is", "it", "its", "itself", "just", "kind", "kg", "km", "last",
  "latter", "latterly", "less", "lest", "let", "like", "little", "ltd", "many", "may", "maybe",
  "me", "meantime", "meanwhile", "might", "moreover", "most", "mostly", "more", "mr", "mrs",
  "ms", "much", "must", "my", "myself", "namely", "need", "neither", "never", "nevertheless",
  "next", "no", "nobody", "none", "nonetheless", "noone", "nope", "nor", "not", "nothing",
  "notwithstanding", "now", "nowadays", "nowhere", "of", "off", "often", "ok", "on", "once",
  "one", "only", "onto", "or", "other", "others", "otherwise", "ought", "our", "ours",
  "ourselves", "out", "outside", "over", "own", "per", "perhaps", "plenty", "provide", "quite",
  "rather", "really", "round", "said", "sake", "same", "sang", "save", "saw", "see", "seeing",
  "seem", "seemed", "seeming", "seems", "seen", "seldom", "selves", "sent", "several", "shalt",
  "she", "should", "shown", "sideways", "since", "slept", "slew", "slung", "slunk", "smote",
  "so", "some", "somebody", "somehow", "someone", "something", "sometime", "sometimes",
  "somewhat", "somewhere", "spake", "spat", "spoke", "spoken", "sprang", "sprung", "stave",
  "staves", "still", "such", "supposing", "than", "that", "the", "thee", "their", "them",
  "themselves", "then", "thence", "thenceforth", "there", "thereabout", "thereabouts",
  "thereafter", "thereby", "therefore", "therein", "thereof", "thereon", "thereto", "thereupon",
  "these", "they", "this", "those", "thou", "though", "thrice", "through", "throughout", "thru",
  "thus", "thy", "thyself", "till", "to", "together", "too", "toward", "towards", "ugh",
  "unable", "under", "underneath", "unless", "unlike", "until", "up", "upon", "upward",
  "upwards", "us", "use", "used", "using", "very", "via", "vs", "want", "was", "we", "week",
  "well", "were", "what", "whatever", "whatsoever", "when", "whence", "whenever", "whensoever",
  "where", "whereabouts", "whereafter", "whereas", "whereat", "whereby", "wherefore",
  "wherefrom", "wherein", "whereinto", "whereof", "whereon", "wheresoever", "whereto",
  "whereunto", "whereupon", "wherever", "wherewith", "whether", "whew", "which", "whichever",
  "whichsoever", "while", "whilst", "whither", "who", "whoa", "whoever", "whole", "whom",
  "whomever", "whomsoever", "whose", "whosoever", "why", "will", "wilt", "with", "within",
  "without", "worse", "worst", "would", "wow", "ye", "yet", "year", "yippee", "you", "your",
  "yours", "yourself", "yourselves" 
  ]


end

# Extention of the standard class String with useful function.
class String
  include RIR

  # Returns +true+ if +self+ belongs to Rir::Stoplist, +false+ otherwise.
  def is_stopword?
    Stoplist.include?(self.downcase)
  end

  # Do not use.
  # TODO: rewamp. find why this function is here.
  def remove_special_characters
    self.split.collect { |w| w.gsub(/\W/,' ').split.collect { |w| w.gsub(/\W/,' ').strip.sub(/\A.\z/, '')}.join(' ').strip.sub(/\A.\z/, '')}.join(' ')
  end

  # Removes all XML-like tags from +self+.
  #
  #   s = "<html><body>test</body></html>"
  #   s.strip_xml_tags!                 
  #   s                                     #=> "test"
  def strip_xml_tags!
    replace strip_with_pattern /<\/?[^>]*>/
  end

  # Removes all XML-like tags from +self+.
  #
  #   s = "<html><body>test</body></html>"
  #   s.strip_xml_tags                      #=> "test"
  #   s                                     #=> "<html><body>test</body></html>"
  def strip_xml_tags
    dup.strip_xml_tags!
  end

  # Removes all Javascript sources from +self+.
  #
  #   s = "<script type='text/javascript'> 
  #         var skin='vector',
  #         stylepath='http://bits.wikimedia.org/skins-1.5'
  #        </script>
  #
  #        test"
  #   s.strip_javascripts!                                  
  #   s                                     #=> "test"
  def strip_javascripts!
    replace strip_with_pattern /<script type="text\/javascript">(.+?)<\/script>/m 
  end

  # Removes all Javascript sources from +self+.
  #
  #   s = "<script type='text/javascript'> 
  #         var skin='vector',
  #         stylepath='http://bits.wikimedia.org/skins-1.5'
  #        </script>
  #
  #        test"
  #   s.strip_javascripts                   #=> "test"                                  
  def strip_javascripts
    dup.strip_javascripts!
  end

  def strip_stylesheets!
  # TODO: rewamp. dunno what is it.
    replace strip_with_pattern /<style type="text\/css">(.+?)<\/style>/m 
  end

  def strip_stylesheets
    dup.strip_stylesheets!
  end

  # Removes punctuation from +self+.
  #
  #   s = "hello, world. how are you?!"
  #   s.strip_punctuation!
  #   s                                 # => "hello world how are you"
  def strip_punctuation!
    replace strip_with_pattern /[^a-zA-Z0-9\-\s]/
  end

  # Removes punctuation from +self+.
  #
  #   s = "hello, world. how are you?!"
  #   s.strip_punctuation               # => "hello world how are you"
  def strip_punctuation
    dup.strip_punctuation!
  end

  # Returns the text values inside all occurences of a XML tag in +self+
  #
  #   s = "four-piece in <a href='#'>Indianapolis</a>, <a href='#'>Indiana</a> at the Murat Theatre"
  #   s.extract_xmltags_values 'a' #=> ["Indianapolis", "Indiana"]
  def extract_xmltags_values(tag_name)
    self.scan(/<#{tag_name}.*?>(.+?)<\/#{tag_name}>/).flatten
  end

  def strip_with_pattern(pattern)
    require 'cgi'
    require 'kconv'
    CGI::unescapeHTML(self.gsub(pattern,"")).toutf8
  end

  private :strip_with_pattern
end
