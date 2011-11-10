module Marples
  class NullTransport
    include Singleton
    def publish *args; end
    def subscribe *args; end
    def join; end
    def to_s; 'Null Transport'; end
  end
end
