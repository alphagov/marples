module Marples
  class NullTransport
    include Singleton
    def publish *args; end
    def subscribe *args; end
  end
end
