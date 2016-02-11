Middlewear
==========

Add a middleware stack to any project.


## Usage

To avoid possible contamination of stacks if multiple projects are used that depend on it, create your own middleware
module:

```ruby
require 'middlewear'

module MyApp
  module Middleware
    include Middlewear
  end
end
```

Now you can add middleware to the stack. Middleware classes can be written in such a way as to accept arguments.

```ruby
MyApp::Middleware.add(MyMiddleware)
MyApp::Middleware.add(MyArgumentativeMiddleware, 'foo')
```

Users will be able to manipulate a middleware stack after the fact:

```ruby
MyApp::Middleware.delete(SomeMiddleware)
MyApp::Middleware.insert_before(SomeMiddleware, OtherMiddleware)
MyApp::Middleware.insert_after(SomeMiddleware, OtherMiddleware)
MyApp::Middleware.insert_after(SomeMiddleware, OtherMiddleware, 'with', 'arguments')
```

Middleware should be written in the following format:

```ruby
class MyMiddleware
  def initialize(app)
    @app = app
  end
  
  def call(foo)
    puts foo        # do some arbitrary work
    @app.call(foo)  # ensure that the rest of the middleware stack is called
  end
end
```

Now in order to actually process the stack, use the `#app` method provided on the module:

```ruby
MyApp::Middleware.app.call(foo) do |foo|
  # do
  # the
  # actual
  # application
  # stuff
end
```

Note that we pass a single argument to the `#call` method. This is arbitrary. Middleware can be written to take any
number of arguments, so long as all of the registered middleware matches the call signature and it matches the number
of arguments of the block passed to `app.call`.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/middlewear. This project is i
ntended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

