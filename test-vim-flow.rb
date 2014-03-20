#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'


pid = Process.spawn('vim .COMMIT_MSG')

Process.waitpid(pid)

puts "Existing"

begin
  puts IO.read('.COMMIT_MSG')
  puts FileUtils.rm_f('.COMMIT_MSG')
rescue
  puts $!
end

