#!/usr/bin/env ruby

#--
# This file is a part of the mirimiri library
#
# Copyright (C) 2010-2012 Romain Deveaud <romain.deveaud@gmail.com>
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

module Mirimiri

  # This class represents one line of a TREC-formatted retrieval
  # result. Typical output of Indri or Terrier.
  class TrecResult
    attr_accessor :topic, :doc, :rank, :score, :run

    def initialize arg
      t = arg.split 
      @topic = t[0]
      @doc   = t[2]
      @rank  = t[3]
      @score = t[4]
      @run   = t[5]
    end
  end

  # This class represents the output of trec_eval, when
  # -q option is given.
  class TrecEval
    attr_accessor :metric, :run, :queries

    def initialize arg
      @queries = {}

      arg.each_line do |line|
        t = line.split
        @metric = t[0] if @metric.nil?
        @queries[t[1]] = t[2].to_f if t[1].is_integer?
      end
    end
  end

  # An array of TrecResult, or a run.
  class TrecResults < Array

    def initialize args
      super args.collect { |res| TrecResult.new res }
    end
  end
end
