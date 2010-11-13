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

  class Query
  end

  module Indri

    class Parameters
      attr_accessor :corpus, :memory, :count, :offset, :run_id, :print_query, :print_docs, :rule, :baseline

      def initialize(corpus,mem="1g",count="1000",offset="1",run_id="default",print_query=false,print_docs=false)
        @corpus      = corpus
        @memory      = mem
        @count       = count
        @offset      = offset
        @run_id      = run_id
        @print_query = print_query ? "true" : "false"
        @print_docs  = print_docs  ? "true" : "false"
      end

      def to_s
        h = "<parameters>\n"
        h += "<memory>#{@memory}</memory>\n"
        h += "<index>#{@corpus}</index>\n"
        h += "<count>#{@count}</count>\n"
        unless @baseline.nil?
          h += "<baseline>#{@baseline}</baseline>\n" 
        else
          h += "<rule>#{@rule}</rule>\n"
        end
        h += "<queryOffset>#{@offset}</queryOffset>\n"
        h += "<runID>#{@run_id}</runID>\n"
        h += "<printQuery>#{@print_query}</printQuery>\n"
        h += "<printDocuments>#{@print_docs}</printDocuments>\n"

        h
      end
    end
    
    class IndriQuery < Query
      attr_accessor :id, :query, :params, :rule

      def initialize(id,query,params)
#        @params = Parameters === params ? params : Parameters.new(corpus)
        @params = params
        # Here we set the default retrieval model as Language Modeling
        # with a Dirichlet smoothing at 2500.
        # TODO: maybe a Rule class...
        @params.rule  = 'method:dirichlet,mu:2500' if @params.rule.nil?

        @id     = id
        @query  = query
      end

      def to_s
        h = @params.to_s
        h += "<query>\n"
        h += "<number>#{@id}</number>\n"
        h += "<text>#{@query}</text>\n"
        h += "</query>\n"
        h += "</parameters>"

        h
      end
    end

  end
end
