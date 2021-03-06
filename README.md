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

```
$ gem install sinatra-params-validator
```

```ruby
require 'rack/validator/sinatra'
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
    { :name => :private, :type => :boolean, :required => true },
    { :name => :type, :set => %{public private}, :default => 'public' },
    { :name => :param, :action => [ :trim, :downcase ] }
  ]

  post '/group' do

  end

end
```

Try it out yourself and run this in the root directory `rackup example/app.rb`.

__NOTE__ Every parameter that is used for that particular request needs to be mentioned in the params
array. Every parameter that hasn't been mentioned will be delete and won't be available in the sinatra
`params` variable when your sinatra code block is invoked.

## Error Messages

Once an error occurs during validation, all the errors are kept in 3 environmental variables `@env['validator.messages']`,
`@env['validator.invalid']` and `@env['validator.missing']`. All 3 variables are arrays. Check them out

Error Format inside the 'validator.messages' variable looks something like this:

```
{
  :name => "private", :error => :NOT_BOOLEAN
}

or

{
  :name => "age", :error => :NOT_IN_RANGE, :value => [ 0, 120 ]
}
```

You can catch these errors and warp them around your own custom responses.

## Validator class

A class with several methods to validate and clean data from sinatra params holder.
Can be used as a basis for an adopter for other libraries/frameworks, like rails.

### Examples

Initialize class in lazy mode, this means that once a validation fail the following ones are not executed:

```ruby
require 'rack/validator'

validator = Rack::Validator.new(params)
#required_3 is not present
validator.required [:required_1, :required_2, :required_3]
validator.trim :required_1
validator.downcase :required_2
validator.downcase :other
validator.is_in_range 3, 32, :required_1
validator.is_email :contact
validator.is_boolean :private
validator.is_set %{public private}, :type
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
* is_set
* is_boolean
* matches
* clean_parameters

To see more examples check tests/params_validator_spec.rb

## Contribution

If you like the project, fork me and help make sinatra better.
Make sure to include test cases and explanation for the implemented feature.