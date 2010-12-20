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

class Corpus
  attr_accessor :path

  def initialize(path)
    @path = path.chomp "/"
  end

  # Recursively outputs all files in +self.path+.
  # WARNING ! This function may take a lot of time if many
  # files are in subdirectories.
  #
  #   c = Corpus.new "my/path"
  #   c.files                  # => ["README.txt", "lib/code.rb"]
  def files
    Dir["#{@path}/**/*.*"]
  end
end
