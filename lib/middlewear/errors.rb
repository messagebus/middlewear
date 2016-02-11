module Middlewear
  class Error < StandardError; end
  class MiddlewareNotFound < Error; end
  class DuplicateMiddleware < Error; end
end
