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

class Downloader
  def initialize(handler, output)
    @handler = handler
    @output = output
  end

  def download(name, directory)
    @output.puts "Downloading #{name}"
    url = @handler.manifest(name).packages.source
    @output.puts "  from: #{url}"
    file_path = File.join(directory, File.basename(url))
    @output.puts "  to: #{file_path}"
    File.open(file_path, "w") do |f|
      f.write(read_from_url(url))
    end
  end

  def read_from_url(url)
    URI.parse(url).open.read
  end
end
