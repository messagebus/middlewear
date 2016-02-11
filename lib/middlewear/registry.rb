module Middlewear
  # A Register of a middleware class that messages will be passed through
  # on the way to being dispatched.
  class Register < Struct.new(:klass, :args)
    def create_new(app)
      klass.new(app, *args)
    end
  end

  # Registry holds records of each middleware class that is added to the
  # consumer middleware chain.
  class Registry
    include Enumerable

    attr_reader :registry

    def initialize(registry = [])
      @registry = registry
    end

    def all
      registry
    end

    def each(&blk)
      all.each(&blk)
    end

    def delete(klass)
      registry.reject! { |register| register.klass == klass }
    end

    def <<(klass_args)
      insert(-1, klass_args[0], klass_args[1])
    end

    def index_of(klass)
      registry.find_index { |register| register.klass == klass }
    end

    def insert(index, klass, args)
      raise DuplicateMiddleware if index_of(klass)
      registry.insert(index, Register.new(klass, args))
    end
  end
end
