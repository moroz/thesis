#!/usr/bin/env ruby
# frozen_string_literal: true

OUTFILE = 'thesis_with_index'
INDEXED_OUTPUT = 'indexed'

def read_patterns(filename)
  hash = {}
  File.open(filename).each_line do |line|
    array = line.chomp.split(/\t+|\s{3,}/)
    if array.length == 1
      hash.merge!(Hash[array[0], array[0]])
    else
      hash.merge!(Hash[*array])
    end
  end
  hash
end

def read_paragraphs(*filenames)
  array = filenames.map do |file|
    File.read(file).split(/\n{2,}/)
  end
  array.flatten
end

def search_pattern(text)
  Regexp.new('(?<=\\\\textit\{|[^\{])(' + text + ')(?!\\\\index\{)')
end

def sub_pattern(text)
  '\1\index{' + text + '}'
end

def remove_comment_blocks(str)
  str.gsub(/\\if 0.+\\fi/m, '')
end

default_files = %w[introduction.tex esperanto.tex chapter_three.tex]
paragraphs = read_paragraphs(*default_files)
patterns = read_patterns('patterns.txt')

patterns.each do |key, val|
  paragraphs = paragraphs.map do |par|
    par.sub search_pattern(key), sub_pattern(val)
  end
end

File.write "#{INDEXED_OUTPUT}.tex", paragraphs.join("\n\n")
compile_command = "xelatex #{OUTFILE}"
system compile_command
system "makeindex #{OUTFILE}.idx"
system compile_command
system compile_command

# File.delete(*Dir['./*.log', './*.ilg', './*.idx', './*.ind'])
File.delete(*Dir['./*.log'])
