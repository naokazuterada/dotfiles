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
          ".gemrc",
          ".gitconfig",
          ".gitignore_global",
          ".rspec",
          ".tigrc",
          ".zpreztorc",
          ".zshgit",
          ".zshrc"
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

  desc "Create symbolic link to HOME/.zshgit"
  task :link do

    # If `.zshgit` is already exist, backup it
    if File.exist?(File.join(HOME, ".zshgit")) && !File.symlink?(File.join(HOME, ".zshgit"))
      mv File.join(HOME, ".zshgit"), File.join(HOME, ".zshgit.org")
    end

    symlink_ File.join(PWD, "zsh/zshrc"), File.join(HOME, ".zshrc")
  end
end

namespace :pip do
  desc "Create symbolic link to HOME/.pip/pip.conf"
  task :link do
    files  =  Dir.glob("pip" +  "/*").map{|path| File.basename(path)}
    FileUtils.mkdir_p(File.join(HOME, ".pip"))
    symlink_ File.join(PWD, "pip", "pip.conf"), File.join(HOME, ".pip", "pip.conf")
  end
end

namespace :etc do
  task :link do
    files  =  Dir.glob("etc" +  "/*").map{|path| File.basename(path)}
    same_name_symlinks File.join(PWD, "etc"), files
  end
end
