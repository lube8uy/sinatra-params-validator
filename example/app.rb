require File.join(File.dirname(__FILE__), '..', 'lib', 'rack', 'validator', 'sinatra')

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