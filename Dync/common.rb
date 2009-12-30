require 'pp'

class Array
	def add(value)
		self[self.size] = value
	end
end
