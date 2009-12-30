require 'common'
require 'matching'

$macros = {}
class Macro
	def initialize(name, pattern, &block)
		$macros[name] = self
		
		@name = name
		@pattern = pattern
		@block = block
	end
	
	def run(code)
		code.match @pattern, &@block
	end
end

def macro(name, pattern, &block)
	Macro.new(name, pattern, &block)
end

print = macro :Print, [:expr, :print, :exprs.capture_rest([:string, String])] do |exprs|
	exprs
end

pp print.run([:expr, :print, [:string, "Hello World!"]])
# [[:string, "Hello World!"]]
