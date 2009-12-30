require 'pp'

require 'parser'
require 'macros'

code = File.new(ARGV[0]).read
code = Parser.new.parse(code)
pp code
