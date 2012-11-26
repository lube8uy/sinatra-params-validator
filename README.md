sinatra-params-validator
========================

A class with several methods to validate and clean data from sinatra params holder.

== Examples

Initialize class in lazy mode, this means that once a validation fail the following ones are not executed:

	validator = ParamsValidator.new(params)
	#required_3 is not present
	validator.required [:required_1, :required_2, :required_3]
	validator.trim
	validator.downcase [:required_2, :other_param]
	validator.is_in_range 3, 32, :required_1
	validator.is_email :contact
	validator.matches /[a-z]{2}_[A-Z]{2}|[a-z]{2}/i, :locale

	if validator.has_errors?
		p validator.messages.join('|')
		#Inputs "required_3 is required"
	end
	
If you want to get all the errors at the end of the validation calls pass false as second parameter in the constructor:
	validator = ParamsValidator.new(params, true)
	
Available methods:

* trim
* downcase
* required
* is_integer
* is_float
* is_greater_equal_than
* is_in_range
* is_less_equal_than
* is_email
* matches

To see more examples check tests/params_validator_spec.rb
