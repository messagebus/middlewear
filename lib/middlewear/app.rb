module Middlewear
  # An App is instantiated and given a stack of instantiated Middleware objects.
  # An app can by called with multiple arguments, excepting for the fact that the
  # call signature used must match every middleware in the stack. It can be called
  # with a block, which gets appended to the chain.
  #
  # Usage:
  #
  #   app = App.new
  #   middleware = Middleware.new(app)
  #   app.stack = [middleware]
  #
  #   app.call(message) do |message|
  #     # do work
  #   end
  #
  class App
    attr_accessor :stack

    def call(*args, &block)
      stack << block if block_given?
      current_register = stack.shift
      current_register.call(*args) if current_register
    end
  end
end
