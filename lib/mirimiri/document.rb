#!/usr/bin/env ruby

#--
# This file is a part of the mirimiri library
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


# General module
module Mirimiri

  # A Document is a bag of words and is constructed from a string.
  class Document
    attr_reader :words, :doc_content, :xcount

    # Any non-word characters are removed from the words (see http://perldoc.perl.org/perlre.html
    # and the \\W special escape).
    # 
    # Protected function, only meant to by called at the initialization.                 
    def format_words
      wo = []

      @doc_content.split.each do |w|
        w.split(/\W/).each do |sw| 
          wo.push(sw.downcase) if sw =~ /[[:alpha:]]/ 
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

      if @ngrams[n].nil?
        @words.each do |w|
          window.push(w)
          if window.size == n
            ngrams_array.push window.join(" ")
            window.delete_at(0)
          end
        end
        @ngrams[n] = ngrams_array
      end

      @ngrams[n]
    end

    # Returns a Hash containing the words and their associated counts in the current Document.
    #
    #   count_words #=> { "guitar"=>1, "bass"=>3, "album"=>20, ... } 
    def count_words
      counts = Hash.new { |h,k| h[k] = 0 }
      @words.each { |w| counts[w] += 1 }

      counts
    end

    # Old entropy function.
    # TODO: remove.
    def entropy0(s)
      en = 0.0

      s.split.each do |w|
        p_wi = @xcount[w].to_f/@words.count.to_f
        en += p_wi*Math.log2(p_wi)
      end

      en *= -1
      en
    end

    # Computes the entropy of a given string +s+ inside the document.
    #
    # If the string parameter is composed of many words (i.e. tokens separated
    # by whitespace(s)), it is considered as an ngram.    
    #
    #   entropy("guitar") #=> 0.014348983965324762
    #   entropy("dillinger escape plan") #=> 0.054976093116768154
    def entropy(s)
      en = 0.0
      
      size = s.split.size
      
      if size == 1
        p_wi = @xcount[s].to_f/@words.count.to_f
        en += p_wi*Math.log(p_wi)
      elsif size > 1
        ng_size = ngrams(size)
        p_wi = ng_size.count(s).to_f/ng_size.count.to_f
        en += p_wi*Math.log(p_wi)
      end

      en *= -1
      en
    end

    # Computes the term frequency of a given *word* +s+.
    #
    #   tf("guitar") #=> 0.000380372765310004
    def tf(s)
      @xcount[s].to_f/@words.size.to_f
    end

    # Computes the KL divergence between the language model of the +self+
    # and the language model of +doc+. 
    #
    # KL is not symmetric, see http://en.wikipedia.org/wiki/Kullback-Leibler_divergence
    # for more information.
    #
    #   d1.kl(d2) #=> 0.2971808085725761
    def kl(doc)
      raise ArgumentError, 'Argument is not a Mirimiri::Document' unless doc.is_a? Mirimiri::Document 
     
      vocab = self.words & doc.words

      vocab.inject(0.0) { |res,w| res + self.tf(w)*Math.log(self.tf(w)/doc.tf(w)) }
    end

    def initialize(content="")
      @doc_content = content
      @words = format_words
      @xcount = count_words
      @ngrams = {}
    end

    protected :format_words, :count_words
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
    def initialize(url,only_tags=nil)
      require 'sanitize'

      @url = url
      content = only_tags.nil? ? WebDocument.get_content(url) : WebDocument.get_content(url).extract_xmltags_values(only_tags).join("")
      super Sanitize.clean(content, :remove_contents => ['script','style'])
    end
  end

  # A WikipediaPage is a WebDocument.
  class WikipediaPage < WebDocument
    require 'rexml/document'
    require 'net/http'
    require 'kconv'


    def self.search_wikipedia_titles(name)
#      raise ArgumentError, "Bad encoding", name unless name.isutf8

      res = REXML::Document.new(Net::HTTP.get( URI.parse "http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=#{URI.escape name}&srlimit=20&format=xml" ).force_encoding("ISO-8859-1").encode("UTF-8")).elements['api/query/search']

     res.collect { |e| e.attributes['title'] } unless res.nil?
    end

    def self.get_url(name)
      raise ArgumentError, "Bad encoding", name unless name.isutf8

      atts = REXML::Document.new(Net::HTTP.get( URI.parse "http://en.wikipedia.org/w/api.php?action=query&titles=#{URI.escape name}&inprop=url&prop=info&format=xml" ).unaccent.toutf8).elements['api/query/pages/page'].attributes

      atts['fullurl'] if atts['missing'].nil?
    end

    def self.search_homepage(name)
      title = WikipediaPage.search_wikipedia_titles name

      WikipediaPage.get_url(title[0]) unless title.nil? || title.empty?
    end

    def self.extract_anchors(url)
      self.get_content(url).extract_xmltags_values('p').join(' ').scan(/<a href="(.+?)" title=.*?>(.+?)<\/a>/).delete_if { |a| a[0] =~ /^\/wiki\/.*$/.negated }
    end
  end

  class FreebasePage < WebDocument
    require 'net/http'
    require 'kconv'
    require 'json'

    def self.search_article_ids query,limit
      raise ArgumentError, "Bad encoding", name unless name.isutf8

      JSON.parse(Net::HTTP.get( URI.parse "http://api.freebase.com/api/service/search?query=#{query.gsub(" ","+")}&limit=#{limit}" ))['result'].collect { |a| a['article']['id'] unless a['article'].nil? }.compact
    end

    def self.get_url id
      "http://api.freebase.com/api/trans/raw#{id}"
    end
  end
end
