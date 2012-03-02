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

class Index
end

module Indri

  class IndriIndex

    def exec indriquery
      raise ArgumentError, 'Argument is not an IndriQuery' unless indriquery.is_a? Indri::IndriQuery
  
      query = "IndriRunQuery -query#{indriquery.query} -index=#{@path}"

      query += " -count=#{indriquery.count}" unless indriquery.count.nil?
      query += " -rule=method:#{indriquery.sm_method},#{indriquery.sm_param}:#{indriquery.sm_value}" unless indriquery.sm_method.nil?
      query += " #{indriquery.args}" unless indriquery.args.nil?
    end
  end
end
