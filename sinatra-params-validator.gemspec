$: << File.dirname(__FILE__) + "/lib"

Gem::Specification.new do |spec|
  spec.name           = "sinatra-params-validator"
  spec.version        = IO.read("VERSION")
  spec.authors        = ["tsov", "lube8uy"]
  spec.email          = "tsov@me.com"
  spec.homepage       = "http://github.com/tsov/#{spec.name}"
  spec.summary        = "A Sinatra Module to validate incoming parameters"
  spec.description    = "This sinatra module validates the incoming parameter and lets you configure the pattern."

  spec.files          = Dir["lib/**/*", "VERSION", "LICENSE", "README.md", "Gemfile", "*.gemspec"]
  spec.license          = "MIT"
end
