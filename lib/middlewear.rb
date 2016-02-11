require 'middlewear/app'
require 'middlewear/errors'
require 'middlewear/registry'
require 'middlewear/version'

module Middlewear
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods
    def add(klass, *args)
      registry << [klass, args]
    end

    def add_before(before_klass, klass, *args)
      idx = registry.index_of(before_klass)
      raise MiddlewareNotFound.new("#{before_klass} not registered in middleware stack") unless idx
      registry.insert(idx, klass, args)
    end

    def add_after(after_klass, klass, *args)
      idx = registry.index_of(after_klass)
      raise MiddlewareNotFound.new("#{after_klass} not registered in middleware stack") unless idx
      registry.insert(idx + 1, klass, args)
    end

    def delete(klass)
      registry.delete(klass)
    end

    # The current registry of middleware. Note that this registry is not a set
    # of instantiated middleware objects, but a registry of the classes themselves.
    def registry
      @registry ||= Registry.new
    end

    def create_stack(app)
      registry.map { |r| r.create_new(app) }
    end

    # When called, this creates a new instance of an App with new instances of
    # each registered middleware. To avoid contamination between calls, this
    # instantiates a new set of objects each time it is called.
    def app
      App.new.tap do |app|
        app.stack = create_stack(app)
      end
    end
  end
end
