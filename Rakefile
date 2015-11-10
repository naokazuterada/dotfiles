# -*- coding: utf-8 -*-
require 'rake/clean'

HOME = ENV["HOME"]
PWD = File.dirname(__FILE__)
OS = `uname`

def symlink_ file, dest
  symlink file, dest if not File.exist?(dest)
end

def same_name_symlinks root, files
  files.each do |file|
    symlink_ File.join(root, file), File.join(HOME, "." + file)
  end
end

cleans = [
          ".zshrc",
          ".gitconfig",
          ".gitignore_global",
          ".tigrc",
          ".gemrc",
          ".rspec"
         ]

CLEAN.concat(cleans.map{|c| File.join(HOME,c)})

task :default => :setup
task :setup => [
              "zsh:link",
              "etc:link"
            ]

namespace :zsh do
  desc "Create symbolic link to HOME/.zshrc"
  task :link do

    # If `.zshrc` is already exist, backup it
    if File.exist?(File.join(HOME, ".zshrc")) && !File.symlink?(File.join(HOME, ".zshrc"))
      mv File.join(HOME, ".zshrc"), File.join(HOME, ".zshrc.org")
    end

    symlink_ File.join(PWD, "zsh/zshrc"), File.join(HOME, ".zshrc")
  end
end

namespace :etc do
  task :link do
    etcs  =  Dir.glob("etc" +  "/*").map{|path| File.basename(path)}
    same_name_symlinks File.join(PWD, "etc"), etcs
  end
end
