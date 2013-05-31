require 'rubygems'
require_relative 'spec_helper'

describe "Rack::Validator test" do

	it "should trim all params" do
		params = {"one" => "  before", "two" => "after  ",  "three" => "  everywhere ", "four" => nil}
		validator = Rack::Validator.new(params, false)
		validator.trim()
		params.keys.each{ |k|
			if params[k]
				params[k][/\s/].should == nil
			end
		}
	end

	it "should downcase params" do
		params = {"one" => "BEFORE", "two" => "2", "three" => nil}
		validator = Rack::Validator.new(params, false)
		validator.downcase([:one, :two, :three, :not_exists])
		params["one"][/[A-Z]/].should == nil
	end

	it "should not return an error when all params are present" do
		params = {"one" => "1", "two" => "2", "three" => "3", "four" => "4"}
		validator = Rack::Validator.new(params, false)
		validator.required(["one", "three"])
		validator.has_errors?.should == false
		validator.invalid_params.should == []
		validator.messages.should == []
	end

	it "should return an error when params are missing" do
		params = {"one" => "1", "two" => "2", "three" => "3", "four" => "4"}
		validator = Rack::Validator.new(params, false)
		validator.required(["one", "five", "three", "six"])
		validator.has_errors?.should == true
		validator.invalid_params.should == ["five", "six"]
		validator.messages.should == ["five is required", "six is required"]
	end

	it "should return is_int = true for integers" do
		params = {"one" => 1, "three" => 3.5, "four" => -99, "five" => "5", "six" => "8.9"}
		validator = Rack::Validator.new(params, false)
		validator.is_integer("one")
		validator.is_integer("four")
		validator.is_integer("five")
		validator.messages.should == []
		validator.has_errors?.should == false
	end

	it "should return is_float = true for integers or floats" do
		params = {"one" => "1", "three" => "3.5", "four" => "-99", "five" => "5", "six" => "8.9", "seven" => "-99.98"}
		validator = Rack::Validator.new(params, false)
		validator.is_float("three")
		validator.is_float("six")
		validator.is_float("one")
		validator.is_float("five")
		validator.is_float("six")
		validator.messages.should == []
		validator.has_errors?.should == false
	end

	it "should return an error when a string is not a number" do
		params = {"one" => "uno", "two" => "dos.2", "three" => "3.tres"}
		validator = Rack::Validator.new(params, false)
		validator.is_float("one")
		validator.is_float("two")
		validator.is_float("three")
		validator.is_float("not_exists")
		validator.has_errors?.should == true
		validator.invalid_params.should == ["one", "two", "three", "not_exists"]
	end

	it "should return an error when a string or number is not an integer" do
		params = {"one" => "uno", "two" => "dos2", "three" => "3tres", "four" => 5.9}
		validator = Rack::Validator.new(params, false)
		validator.is_integer("one")
		validator.is_integer("two")
		validator.is_integer("three")
		validator.is_integer("four")
		validator.is_integer("not_exists")
		validator.has_errors?.should == true
		validator.invalid_params.should == ["one", "two", "three", "four", "not_exists"]
	end

	it "should return an error when the lenght of the value is < 5" do
		params = {"one" => "uno1", "two" => "3", "three" => nil}
		validator = Rack::Validator.new(params, false)
		validator.is_greater_equal_than(5, "one")
		validator.is_greater_equal_than(5, "two")
		validator.is_greater_equal_than(5, "three")
		validator.is_greater_equal_than(5, "not_exists")
		validator.has_errors?.should == true
		validator.invalid_params.should == ["one", "two", "three", "not_exists"]
	end

	it "should not return an error when the lenght of the value is >= 5" do
		params = {"one" => "uno12345", "two" => 9, "three" => 5, "four" => "5"}
		validator = Rack::Validator.new(params, false)
		validator.is_greater_equal_than(5, "one")
		validator.is_greater_equal_than(5, "two")
		validator.is_greater_equal_than(5, "three")
		validator.is_greater_equal_than(5, "four")
		validator.invalid_params.should == []
		validator.has_errors?.should == false
	end

	it "should return an error when the lenght of the value is > 5" do
		params = {"one" => "uno1233", "two" => "6"}
		validator = Rack::Validator.new(params, false)
		validator.is_less_equal_than(5, "one")
		validator.is_less_equal_than(5, "two")
		validator.is_less_equal_than(5, "not_exists")
		validator.has_errors?.should == true
		validator.invalid_params.should == ["one", "two", "not_exists"]
	end

	it "should not return an error when the lenght of the value is < 5" do
		params = {"one" => "uno", "two" => 2, "three" => 5, "four" => "5"}
		validator = Rack::Validator.new(params, false)
		validator.is_less_equal_than(5, "one")
		validator.is_less_equal_than(5, "two")
		validator.is_less_equal_than(5, "three")
		validator.is_less_equal_than(5, "four")
		validator.invalid_params.should == []
		validator.has_errors?.should == false
	end

	it "should return an error when the lenght of the value is not in range [0..3]" do
		params = {"one" => "-1", "two" => "-1.2", "three" => 3.01, "four" => 6, "five" => "ceee"}
		validator = Rack::Validator.new(params, false)
		validator.is_in_range(0, 3, "one")
		validator.is_in_range(0, 3, "two")
		validator.is_in_range(0, 3, "three")
		validator.is_in_range(0, 3, "four")
		validator.is_in_range(0, 3, "five")
		validator.is_in_range(0, 3, "not_exists")
		validator.has_errors?.should == true
		validator.invalid_params.should == ["one", "two", "three", "four", "five", "not_exists"]
	end

	it "should not return an error when the lenght of the value is in range [0..3]" do
		params = {"one" => "0", "two" => "3", "three" => 2.01, "four" => 2, "five" => "li"}
		validator = Rack::Validator.new(params, false)
		validator.is_in_range(0, 3, "one")
		validator.is_in_range(0, 3, "two")
		validator.is_in_range(0, 3, "three")
		validator.is_in_range(0, 3, "four")
		validator.is_in_range(0, 3, "five")
		validator.has_errors?.should == false
		validator.invalid_params.should == []
	end

	it "should return an error when something doesn't look like an email" do
		params = {"one" => "lucia@emailcom", "two" => "afdklf0", "three" => "@", "four" => "yayaya.com", "five" => 5}
		validator = Rack::Validator.new(params, false)
		validator.is_email("one")
		validator.is_email("two")
		validator.is_email("three")
		validator.is_email("four")
		validator.is_email("five")
		validator.is_email("not_exists")
		validator.invalid_params.should == ["one", "two", "three", "four", "five", "not_exists"]
		validator.has_errors?.should == true
	end

	it "should not return error when something looks like an email" do
		params = {"one" => "lucia@email.com", "two" => "afdklf0@aol.com", "three" => "a.a@a.a.com", "four" => "lucia.fo@hola.com"}
		validator = Rack::Validator.new(params, false)
		validator.is_email("one")
		validator.is_email("two")
		validator.is_email("three")
		validator.is_email("four")
		validator.invalid_params.should == []
		validator.has_errors?.should == false
  end

  it "should not return errors when the parameter value matches the set" do
    params = {"one" => "public"}
    validator = Rack::Validator.new(params, false)
    validator.is_set(%{public private}, "one")
    validator.invalid_params.should == []
    validator.has_errors?.should == false
  end

  it "should return errors when the parameter value does not match the set" do
    params = {"one" => "publicc"}
    validator = Rack::Validator.new(params, false)
    validator.is_set(%{public private}, "one")
    validator.invalid_params.size.should == 1
    validator.has_errors?.should == true
  end

  it "should not return errors when parameter value is boolean" do
    params = {"one" => "true", "two" => "false"}
    validator = Rack::Validator.new(params, false)
    validator.is_boolean("one")
    validator.is_boolean("two")
    validator.invalid_params.should == []
    validator.has_errors?.should == false
  end

  it "should return errors when parameter value is not boolean" do
    params = {"one" => "truee", "two" => "false"}
    validator = Rack::Validator.new(params, false)
    validator.is_boolean("one")
    validator.is_boolean("two")
    validator.invalid_params.size.should == 1
    validator.invalid_params.should == ["one"]
    validator.has_errors?.should == true
  end

	it "should not return errors when a expression matches a regexp" do
		params = {"one" => "hey ho"}
		validator = Rack::Validator.new(params, false)
		validator.matches(/hey/, "one")
		validator.has_errors?.should == false
  end

	it "should return an error when a expression doesn't match a regexp" do
		params = {"one" => "lets go"}
		validator = Rack::Validator.new(params, false)
		validator.matches(/hey/, "one")
		validator.has_errors?.should == true
	end
end