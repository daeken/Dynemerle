require 'common'

class Parser
	def parse(source)
		@source = source
		@pos = 0
		
		parsegroup :group, /;/, nil
	end
	
	def subparse
		if match /\s+/
		elsif match /\(/
			yield parsegroup(:parengroup, /,/, /\)/)
		elsif match /{/
			yield parsegroup(:bracegroup, /;/, /}/)
		elsif match /\[/
			yield parsegroup(:bracketgroup, /,/, /]/)
		elsif match /[a-zA-Z_][a-zA-Z0-9_]*/
			yield @matches[0].to_sym
		elsif match '+-!#$%^&*:.`~=<>/\\'
			yield @matches[0].to_sym
		elsif match /["']/
			yield parsestring
		end
	end
	
	def parsegroup(type, delimiter, ending)
		group = [type]
		subgroup = [:expr]
		
		while true
			break if (ending != nil and match(ending)) or @pos >= @source.size
			
			if match delimiter
				group.add subgroup
				subgroup = [:expr]
				next
			end
			
			subparse do |element|
				subgroup.add element
			end
		end
		
		group.add subgroup if subgroup.size > 1
		
		group
	end
	
	def parsestring
		ending = @matches[0]
		ret = ''
		
		while true
			char = @source[@pos].chr
			@pos += 1
			break if char == ending
			
			if char == '\\'
				char = @source[@pos].chr
				@pos += 1
				
				ret += case char
						when 'n' then "\n"
						when 'r' then "\r"
						when 't' then "\t"
						when ending then ending
					end
			else
				ret += char
			end
		end
		
		[:str, ret]
	end
	
	def match(re)
		if re.is_a? String
			ret = ''
			
			while true
				op = @source[@pos].chr
				if re.include? op
					ret += op
					@pos += 1
				else
					break
				end
			end
			
			if ret != '' then @matches = [ret]
			else @matches = nil
			end
			return @matches
		end
		
		re = re.to_s.split ':', 2
		re = Regexp.new(re[0] + ':^' + re[1])
		
		matches = re.match @source[@pos...@source.size]
		@matches = matches
		if matches == nil then nil
		else
			@pos += matches[0].size
			matches
		end
	end
end
