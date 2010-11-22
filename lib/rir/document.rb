#!/usr/bin/env ruby

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

# General module for many purposes related to Information Retrieval.
module RIR

  # A Document is a bag of words and is constructed from a string.
  class Document
    attr_reader :words, :doc_content

    # Any non-word characters are removed from the words (see http://perldoc.perl.org/perlre.html
    # and the \\W special escape).
    # 
    # Protected function, only meant to by called at the initialization.                 
    def format_words
      wo = []

      @doc_content.split.each do |w|
        w.split(/\W/).each do |sw| 
          wo.push(sw) if sw =~ /[a-zA-Z]/ 
        end
      end
      
      wo
    end

    # Returns an Array containing the +n+-grams (words) from the current Document. 
    #
    #   ngrams(2) #=> ["the free", "free encyclopedia", "encyclopedia var", "var skin", ...]
    def ngrams(n)
      window       = []
      ngrams_array = []

      @words.each do |w|
        window.push(w)
        if window.size == n
          ngrams_array.push window.join(" ")
          window.delete_at(0)
        end
      end

      ngrams_array.uniq
    end

    # Returns a Hash containing the words and their associated counts in the current Document.
    #
    #   count_words #=> { "guitar"=>1, "bass"=>3, "album"=>20, ... } 
    def count_words
      counts = Hash.new { |h,k| h[k] = 0 }
      @words.each { |w| counts[w.downcase] += 1 }

      counts
    end

    # Computes the entropy of a given string +s+ inside the document.
    #
    # If the string parameter is composed of many words (i.e. tokens separated
    # by whitespace(s)), it is considered as an ngram.    
    #
    #   entropy("guitar") #=> 0.00389919463243839
    def entropy(s)
      en = 0.0
      counts = self.count_words

      s.split.each do |w|
        p_wi = counts[w].to_f/@words.count.to_f
        en += p_wi*Math.log2(p_wi)
      end

      en *= -1
      en
    end



    def initialize(content)
      @doc_content = content
      @words = format_words
    end

    protected :format_words
  end

  # A WebDocument is a Document with a +url+.
  class WebDocument < Document
    attr_reader :url

    # Returns the HTML text from the page of a given +url+.
    def self.get_content(url)
      require 'net/http'
      Net::HTTP.get(URI.parse(url))
    end

    # WebDocument constructor, the content of the Document is the HTML page
    # without the tags.
    def initialize(url)
      @url = url
      super WebDocument.get_content(url).strip_javascripts.strip_stylesheets.strip_xml_tags
    end
  end

  # A WikipediaPage is a WebDocument.
  class WikipediaPage < WebDocument
    require 'rexml/document'
    require 'net/http'
    require 'kconv'


    def self.search_wikipedia_titles(name)
      res = REXML::Document.new(Net::HTTP.get(URI.parse("http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=#{URI.escape name}&format=xml")).toutf8).elements['api/query/search']

      res.collect { |e| e.attributes['title'] } unless res.nil?
    end

    def self.get_url(name)
      atts = REXML::Document.new(Net::HTTP.get(URI.parse("http://en.wikipedia.org/w/api.php?action=query&titles=#{URI.escape name}&inprop=url&prop=info&format=xml")).toutf8).elements['api/query/pages/page'].attributes

      atts['fullurl'] if atts['missing'].nil?
    end

    def self.search_homepage(name)
      title = WikipediaPage.search_wikipedia_titles name

      begin
        WikipediaPage.new(WikipediaPage.get_url title[0]) unless title.nil? || title.empty?
      rescue
        puts title[0]
      end
    end

#    def initialize(name)
#      title = WikipediaPage.search_wikipedia_titles name
#      raise ArgumentError, "No page found" if title.empty? 
#      super WikipediaPage.get_url title[0]
#    end
  end
end
