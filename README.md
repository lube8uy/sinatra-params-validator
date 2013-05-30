# sinatra-params-validator
========================

## Description

This sinatra module validates the incoming parameter and lets you configure the pattern.
Once it's registered with your sinatra app, it will act as a before filter, that validates your parameters.
You can configure it with the newly available sinatra method `validation_required`.

## Sinatra Module

Configure your routes to require parameters and validate their values. If the
validator finds errors, it will execute sinatras halt method, which will prevent
invocation of your sinatra code block, and set the response status to 400. The missing
or invalid parameters can be found in the environment variable, like in the example
below. That means you can customize your own error responses, for example by catching the errors
with some middleware.

### Examples

```ruby
require 'sinatra'

class App < Sinatra::Base
  register Rack::Validator::Sinatra

  helpers do
    def missing_parameters
      @env['validator.missing']
    end

    def invalid_parameters
      @env['validator.invalid']
    end

    def messages
      @env['validator.messages']
    end
  end

  after do
    puts missing_parameters
    puts invalid_parameters
    puts messages
    puts params
  end

  validation_required :GET, '/', :params => [
    { :name => :name, :required => true },
    { :name => :email, :type => :email, :required => true },
    { :name => :age, :range => [ 0, 120 ], :default => 1000 },
    { :name => :latitude, :type => :float, :default => 0.0 },
    { :name => :longitude, :type => :float, :default => 0.0 },
    { :name => :message },
    { :name => :price, :matches => /^[\d]*.[\d]{2}$/ }
  ]

  get '/' do

  end

  validation_required :POST, '/group', :params => [
    { :name => :name, :required => true },
    { :name => :private, :type => :boolean, :required => true }
  ]

  post '/group' do

  end

end
```

Try it out yourself and run this in the root directory `rackup example/app.rb`.

## Validator class

A class with several methods to validate and clean data from sinatra params holder.
Can be used for an adopter for other libraries/frameworks, like rails.

### Examples

Initialize class in lazy mode, this means that once a validation fail the following ones are not executed:

```ruby
validator = Rack::Validator.new(params)
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
```

If you want to get all the errors at the end of the validation calls pass false as second parameter in the constructor:
	validator = Rack::Validator.new(params, true)
	
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
* is_boolean
* matches

To see more examples check tests/params_validator_spec.rb
