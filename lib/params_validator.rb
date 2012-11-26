class ParamsValidator

	attr_reader :invalid_params
	attr_reader :messages
	attr_accessor :lazy_mode

	def initialize(params, lazy_mode = true)
		@params = params
		@invalid_params = []
		@messages = []
		@lazy_mode = lazy_mode
	end

	def has_errors?
		@invalid_params.length > 0
	end

	def trim()
		@params.each_key { |k| @params[k] = @params[k].strip if @params[k]}
	end

	def downcase(keys)
		keys.each { |k| @params[k.to_s] = @params[k.to_s].to_s.downcase if @params[k.to_s]}
	end

	def required(keys)
		if lazy_check_disabled
			keys.each { |k|
				k = k.to_s
				if (!@params.has_key?(k))
					@invalid_params.push(k)
					@messages.push("#{k} is required")
				end
			}
		end
	end

	def is_integer(key)
		if lazy_check_disabled
			key = key.to_s
			value = @params[key]
			if !is_valid_integer(value)
				@invalid_params.push(key)
				@messages.push("#{key} is not an integer")
			end
		end
	end

	def is_float(key)
		if lazy_check_disabled
			key = key.to_s
			value = @params[key]
			if !is_valid_float(value)
				@invalid_params.push(key)
				@messages.push("#{key} is not a float")
			end
		end
	end

	def is_greater_equal_than(min, key)
		if lazy_check_disabled
			key = key.to_s
			if !is_valid_float(@params[key])
				if !@params[key] || @params[key].length < min
					@invalid_params.push(key)
					@messages.push("#{key} length is less than #{min}")
				end
			else
				value = is_valid_integer(@params[key]) ? @params[key].to_i : @params[key].to_f
				if  !value || value < min
					@invalid_params.push(key)
					@messages.push("#{key} is less than #{min}")
				end
			end
		end
	end

	def is_in_range(min, max, key)
		if lazy_check_disabled
			key = key.to_s
			if !is_valid_float(@params[key])
				if !@params[key] || @params[key].length < min || @params[key].length > max
					@invalid_params.push(key)
					@messages.push("#{key} length is not in range #{min},#{max}")
				end
			else
				value = is_valid_integer(@params[key]) ? @params[key].to_i : @params[key].to_f
				if !value || value < min || value > max
						@invalid_params.push(key)
						@messages.push("#{key} is not in range #{min},#{max}")
				end
			end
		end
	end

	def is_less_equal_than(max, key)
		if lazy_check_disabled
			key = key.to_s
			if !is_valid_float(@params[key])
				if !@params[key] || @params[key].length > max
					@invalid_params.push(key)
					@messages.push("#{key} length is greater than #{max}")
				end
			else
				value = is_valid_integer(@params[key]) ? @params[key].to_i : @params[key].to_f
				if !value || value > max
					@invalid_params.push(key)
					@messages.push("#{key} is greater than #{max}")
				end
			end
		end
	end

	def is_email(key)
		if lazy_check_disabled
			key = key.to_s
			if !@params[key].to_s[/^\S+@\S+\.\S+$/]
				@invalid_params.push(key)
				@messages.push("#{key} is not a valid email")				
			end
		end
	end

	def matches(regexp, key)
		if lazy_check_disabled
			key = key.to_s
			if !@params[key][regexp]
				@invalid_params.push(key)
				@messages.push("#{key} is not a valid expression")				
			end
		end
	end

	private

	def lazy_check_disabled
		return !@lazy_mode || !has_errors?
	end

	def is_valid_integer(value)
		key = key.to_s
		value.to_i.to_s == value.to_s
	end 

	def is_valid_float(value)
		key = key.to_s
		value.to_f.to_s == value.to_s || is_valid_integer(value)
	end 	
end