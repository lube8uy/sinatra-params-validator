require 'rack'

module Rack
  class Validator

    attr_reader :invalid_params
    attr_reader :missing_params
    attr_reader :messages
    attr_reader :params
    attr_accessor :lazy_mode

    def initialize(params, lazy_mode = true)
      @params = params
      @invalid_params = []
      @missing_params = []
      @messages = []
      @lazy_mode = lazy_mode
    end

    def has_errors?
      @invalid_params.length > 0 or @missing_params.length > 0
    end

    def trim(key)
      @params[key.to_s] = @params[key.to_s].strip if @params[key.to_s]
    end

    def downcase(key)
      @params[key.to_s] = @params[key.to_s].to_s.downcase if @params[key.to_s]
    end

    def required(keys)
      if lazy_check_disabled
        keys.each { |k|
          k = k.to_s
          unless @params.has_key?(k) && !@params[k].empty?
            @invalid_params.push(k)
            @missing_params.push(k)
            @messages.push("#{k} is required")
          end
        }
      end
    end

    def is_integer(key)
      if lazy_check_disabled
        key = key.to_s
        value = @params[key]
        unless is_valid_integer(value)
          @invalid_params.push(key)
          @messages.push("#{key} is not an integer")
        end
      end
    end

    def is_float(key)
      if lazy_check_disabled
        key = key.to_s
        value = @params[key]
        unless is_valid_float(value)
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
        unless is_valid_float(@params[key])
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
        unless is_valid_float(@params[key])
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
        unless @params[key].to_s[/^\S+@\S+\.\S+$/]
          @invalid_params.push(key)
          @messages.push("#{key} is not a valid email")
        end
      end
    end

    def is_set(array, key)
      if lazy_check_disabled
        key = key.to_s
        unless array.include? @params[key]
          @invalid_params.push(key)
          @messages.push("#{key} does not match #{array}")
        end
      end
    end

    def is_boolean(key)
      if lazy_check_disabled
        key = key.to_s
        unless @params[key] == 'true' || @params[key] == 'false'
          @invalid_params.push(key)
          @messages.push("#{key} is not a boolean")
        end
      end
    end

    def matches(regexp, key)
      if lazy_check_disabled
        key = key.to_s
        unless @params[key] =~ regexp
          @invalid_params.push(key)
          @messages.push("#{key} is not a valid expression")
        end
      end
    end

    def clean_parameters(all_parameters)
      @params.each_key do |key|
        @params.delete key.to_s unless all_parameters.include? key.to_s
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

    module Sinatra

      def validation_required(method, path, options = { })
        before path do
          validate_parameters(options) if same_method? method
        end
      end

      module Helpers
        def same_method?(method)
          @env['REQUEST_METHOD'] == method.to_s
        end

        # TODO: Needs a general cleanup!!!
        def validate_parameters(options)
          validator = Rack::Validator.new params, false
          all_params = [ ]
          required_params = [ ]
          integer_params = [ ]
          float_params = [ ]
          email_params = [ ]
          range_params = [ ]
          set_params = [ ]
          boolean_params = [ ]
          matches_params = [ ]
          default_params = [ ]
          action_params = [ ]

          options[:params].each do |param|
            all_params << (param[:name].to_s)
            required_params << (param[:name]) if param[:required]
            integer_params << (param) if param[:type] == :integer
            float_params << (param) if param[:type] == :float
            email_params << (param) if param[:type] == :email
            range_params << (param) if param[:range]
            set_params << (param) if param[:set]
            boolean_params << (param) if param[:type] == :boolean
            matches_params << (param) if param[:matches]
            default_params << (param) if param[:default]
            action_params << (param) if param[:action]
          end

          validator.clean_parameters all_params

          validator.required required_params

          integer_params.each do |param|
            validator.is_integer param[:name] unless params[param[:name].to_s].nil?
          end
          float_params.each do |param|
            validator.is_float param[:name] unless params[param[:name].to_s].nil?
          end
          email_params.each do |param|
            validator.is_email param[:name] unless params[param[:name].to_s].nil?
          end
          range_params.each do |param|
            validator.is_in_range param[:range].first, param[:range].last, param[:name] unless params[param[:name].to_s].nil?
          end
          set_params.each do |param|
            validator.is_set param[:set], param[:name] unless params[param[:name].to_s].nil?
          end
          boolean_params.each do |param|
            validator.is_boolean param[:name] unless params[param[:name].to_s].nil?
          end
          matches_params.each do |param|
            validator.matches param[:matches], param[:name] unless params[param[:name].to_s].nil?
          end

          default_params.each do |param|
            if params[param[:name].to_s].nil?
              params[param[:name].to_s] = param[:default]
              validator.invalid_params.delete param[:name]
              validator.missing_params.delete param[:name]
            end
          end

          action_params.each do |param|
            validator.downcase param[:name] if param[:action].include? :downcase
            validator.trim param[:name] if param[:action].include? :trim
          end

          if validator.has_errors?
            @env['validator.missing'] = validator.missing_params
            @env['validator.invalid'] = validator.invalid_params
            @env['validator.messages'] = validator.messages
            halt missing_params!
          end
        end

        def missing_params!
          @response.status = 400
        end
      end

      def self.registered(base)
        base.helpers Helpers
      end

    end
  end
end