# Copyright (C) 2014 Cornelius Schumacher <schumacher@kde.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

module HasGivenFilesystem
  def self.included(example_group)
    example_group.extend(self)
  end

  def given_filesystem
    before do
      @given_filesystem = GivenFilesystem.new
    end
    
    after do
      @given_filesystem.cleanup
    end
  end
  
  def given_directory directory_name = nil
    @given_filesystem.directory directory_name
  end
  
  def given_file file_name = nil, options = {}
    @given_filesystem.file file_name
  end
end

class GivenFilesystem
  
  def initialize
    @path = [ Dir.tmpdir, "given_filesystem" ]
    @base_paths = Array.new
  end
  
  def cleanup
    @base_paths.each do |base_path|
      # Better safe than sorry, so do sanity check on path before removing it
      if base_path =~ /given_filesystem/
        FileUtils.rm_r base_path
      end
    end
  end

  def directory dir_name = nil
    if !dir_name || @path.last == "given_filesystem"
      @path.push random_name
      @base_paths.push path
    end
    @path.push dir_name if dir_name
    created_path = path
    FileUtils.mkdir_p created_path
    yield if block_given?
    @path.pop
    created_path
  end

  def file file_name = nil, options = {}
    if !file_name || @path.last == "given_filesystem"
      @path.push random_name
      @base_paths.push path
      if file_name
        FileUtils.mkdir_p path
      end
    end
    @path.push file_name if file_name
    created_path = path
    File.open(created_path,"w") do |file|
      if options[:from]
        test_data = test_data_path(options[:from])
        if !File.exists? test_data
          raise "Test data file '#{test_data}' doesn't exist"
        end
        file.puts File.read(test_data)
      else
        file.puts "GivenFilesystem was here"
      end
    end
    @path.pop
    created_path
  end
  
  def random_name
    "#{Time.now.strftime("%Y%m%d")}-#{rand(99999).to_s}"
  end
  
  def path
    @path.join("/")
  end
  
  def test_data_path name
    File.expand_path('spec/data/' + name)
  end
end
