require 'common'

class Array
	def match(*pattern, &block)
		pattern = pattern[0] if pattern.size == 1 and pattern[0].is_a? Array
		
		captures = []
		result = submatch pattern do |capture|
			captures.add capture
		end
		
		return false if result == false
		
		if block == nil
			if captures.size == 1
				captures[0]
			else
				captures
			end
		else
			block.call *captures if block != nil
		end
	end
	
	def submatch(pattern, &block)
		pattern = pattern.pattern if pattern.is_a? Capture
		
		return false if pattern.size != size
		
		(0...size).each do |i|
			subpattern, value = pattern[i], self[i]
			
			if subpattern.is_a? Class and value.is_a? subpattern
			elsif not value.is_a? Array and not subpattern.is_a? Array and subpattern == value
			elsif subpattern == :_
			elsif subpattern.is_a? Array and value.is_a? Array and value.submatch subpattern, &block
			elsif subpattern.is_a? Capture
				captures = []
				if subpattern.rest
					(i...size).each do |j|
						result = [self[j]].submatch subpattern do |capture|
							captures.add capture
						end
						
						return false if result == false
					end
					
					block.call self[i...size]
					captures.each { |capture| block.call capture }
					
					break
				else
					result = [value].submatch subpattern do |capture|
						captures.add capture
					end
					
					return false if result == false
					
					block.call value
					captures.each { |capture| block.call capture }
				end
			else
				return false
			end
		end
		
		true
	end
end

class Capture
	def initialize(symbol, pattern, rest=false)
		@symbol = symbol
		if pattern.size == 0
			@pattern = [:_]
		else
			@pattern = pattern
		end
		@rest = rest
	end
	
	def symbol() @symbol end
	def pattern() @pattern end
	def rest() @rest end
end

class Symbol
	def capture(*pattern)
		Capture.new self, pattern
	end
	
	def capture_rest(*pattern)
		Capture.new self, pattern, true
	end
end
