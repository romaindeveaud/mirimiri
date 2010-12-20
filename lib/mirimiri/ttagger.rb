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


# TreeTagger-related stuff module.
#
# See http://www.ims.uni-stuttgart.de/projekte/corplex/TreeTagger/DecisionTreeTagger.html
module TreeTagger
  
  # This class handles generic parsing of tagger-chunker outputs.
  class TaggerChunker
    attr_reader :chunks, :file


    # Parses a tagger-chunker output and returns an Array of Chunk.
    def self.parse chunk_lines
      open = false
      tag  = nil

      chunks = []
      words  = []

      chunk_lines.each do |l|
        l.chomp!
        if l =~ /^<\w+>$/
          open = true
          tag  = l
        elsif l =~ /^<\/\w+>$/
          if !words.empty? && open && l == tag.sub(/</, '</')
            open = false
            chunks.push Chunk.new(words.join(" "), tag) 
            words.clear
          else
            next
          end
        else
          words.push(l.split.first)
        end
      end

      chunks
    end

    # Initializes parsing. +chunk_file+ is the output of +tagger-chunker-+ and must
    # be a valid path to the file.
    #
    #   TaggerChunker.new("ttout/2010020") #=> #<RIR::TreeTagger::TaggerChunker:0x92fd088 @chunks=[#<RIR::TreeTagger::Chunk:0x8ec5a10 @words=["robert", "schumann"], @tag="NC">, ...] ...>
    def initialize chunk_file
      @chunks = TaggerChunker.parse File.open(chunk_file).readlines
    end

  end

  class TaggerChunkerEnglish < TaggerChunker
  end

  class TaggerChunkerFrench  < TaggerChunker
  end

  class TaggerChunkerGerman  < TaggerChunker
  end

  # Represents a Chunk extracted when parsing a TaggerChunker file.
  class Chunk
    attr_reader :words, :tag

    # Creates a Chunk.
    #
    # * +str+ are whitespace-separated terms.
    # * +tag+ see : ftp://ftp.ims.uni-stuttgart.de/pub/corpora/chunker-tagset-english.txt
    def initialize str,tag
      @words = str.split
      @tag   = tag[1..-2]
    end
  end

end
