# Copyright (C) 2013 Cornelius Schumacher <schumacher@kde.org>
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

class GitHubTool
  
  def self.review repo
    puts "Reviewing repo '#{repo}'"
    
    check_directory
    if `git status` !~ /^# On branch master/
      STDERR.puts "You need to be on the master branch"
      exit 1
    end

    user,branch = parse_repo repo
    
    run "git checkout -b #{user}-#{branch} master"
    run "git pull git@github.com:#{user}/inqlude-data.git #{branch}"
  end

  def self.accept repo
    check_directory

    user,branch = parse_repo repo

    branchname = "#{user}-#{branch}"
    
    if `git status` !~ /^# On branch #{branchname}/
      STDERR.puts "You need to be on the #{branchname} branch"
      exit 1
    end
    
    run "git checkout master"
    run "git merge #{branchname}"
    run "git push origin master"    
  end
  
  def self.check_directory
    current_dir = File.basename Dir.pwd
    if current_dir != "inqlude-data"
      STDERR.puts "inqlude review needs to be run in the inqlude-data directory"
      exit 1
    end
    if !File.exists? ".git"
      STDERR.puts "inqlude-data directory needs to be a git checkout"
      exit 1
    end
  end

  def self.parse_repo repo
    user = repo.split(":")[0]
    branch = repo.split(":")[1]
    
    if !user
      STDERR.puts "Unable to extract user from repo parameter"
      exit 1
    end
    if !branch
      STDERR.puts "Unable to extract branch from repo parameter"
      exit 1
    end
    
    return user,branch
  end
  
  def self.run cmd
    puts "Running: #{cmd}"
    if !system cmd
      raise "Command failed"
    end
  end
  
end
