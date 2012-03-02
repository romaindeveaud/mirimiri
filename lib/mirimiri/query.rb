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

class Query
end

module Indri

  class Parameters
    attr_accessor :index_path, :memory, :count, :offset, :run_id, :print_query, :print_docs, :rule, :baseline

    def initialize(corpus,count="1000",mem="1g",threads="1",offset="1",run_id="default",print_query=false,print_docs=false)
      @index_path  = corpus
      @memory      = mem
      @count       = count
      @threads     = threads
      @offset      = offset
      @run_id      = run_id
      @print_query = print_query ? "true" : "false"
      @print_docs  = print_docs  ? "true" : "false"
    end

    def to_s
      h = "<memory>#{@memory}</memory>\n"
      h += "<index>#{@index_path}</index>\n"
      h += "<count>#{@count}</count>\n"
      h += "<threads>#{@threads}</threads>\n"
      unless @baseline.nil?
        h += "<baseline>#{@baseline}</baseline>\n" 
      else
        h += "<rule>#{@rule}</rule>\n"
      end
      h += "<trecFormat>true</trecFormat>\n"
      h += "<queryOffset>#{@offset}</queryOffset>\n"
      h += "<runID>#{@run_id}</runID>\n"
      h += "<printQuery>#{@print_query}</printQuery>\n"
      h += "<printDocuments>#{@print_docs}</printDocuments>\n"

      h
    end
  end

  class IndriQueryOld < Query
    attr_accessor :id, :query, :rule

    def initialize(id,query)
      @id     = id
      @query  = query
    end

    def to_s
      h = "<query>\n"
      h += "<number>#{@id}</number>\n"
      h += "<text>#{@query}</text>\n"
      h += "</query>\n"

      h
    end

    def exec params
      `IndriRunQuery -query='#{@query}' -index=#{params.index_path} -count=#{params.count} -rule=method:dirichlet,mu:2500 -trecFormat`
    end
  end

  class IndriQuery < Query
    attr_accessor :query, :count, :sm_method, :sm_param, :sm_value, :args

    def initialize atts={},args=nil
      raise ArgumentError, 'Argument 1 must be a Hash' unless args.is_a? Hash
      atts.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end

      raise ArgumentError, 'Argument 2 must be a String' unless args.is_a? String
      @args = args 
    end
  end

  class IndriQueries
    attr_accessor :params, :queries

    def initialize(params,*queries)
      @queries = queries    

      @params = params
      # Here we set the default retrieval model as Language Modeling
      # with a Dirichlet smoothing at 2500.
      # TODO: maybe a Rule class...
      @params.rule  = 'method:dirichlet,mu:2500' if @params.rule.nil?
    end

    def to_s
      h = "<parameters>\n"
      h += @params.to_s
      h += @queries.collect { |q| q.to_s }.join ""
      h += "</parameters>"

      h
    end
  end

end
