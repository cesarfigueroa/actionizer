require 'ostruct'
require 'actionizer/result'
require 'actionizer/failure'
require 'actionizer/version'

module Actionizer
  attr_reader :input, :output

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def method_missing(method_name, *args, &block)
      instance = new(*args)

      if instance.respond_to?(method_name)
        instance.tap(&method_name).output
      else
        super
      end
    rescue Actionizer::Failure => af
      af.output
    end

    def respond_to_missing?(method_name, include_private = false)
      new.respond_to?(method_name, include_private)
    end
  end

  def initialize(initial_input = {})
    @input = OpenStruct.new(initial_input)
    @output = Actionizer::Result.new
  end

  def fail!(params = {})
    params.each_pair { |key, value| output[key] = value }

    output.fail

    raise Actionizer::Failure.new('Failed!', output)
  end

  # Allows you to call *_or_fail
  def method_missing(method_name, *args, &block)
    return super unless method_name.to_s.end_with?('_or_fail')

    action_class, params = *args

    unless action_class.include? Actionizer
      raise ArgumentError, "#{action_class.name} must include Actionizer"
    end

    result = action_class.send(method_name.to_s.chomp('_or_fail'), params)
    fail!(error: result.error) if result.failure?

    result
  end

  def respond_to_missing?(method_name, _include_private = false)
    method_name.to_s.end_with?('_or_fail')
  end
end
