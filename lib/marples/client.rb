module Marples
  class Client
    MESSAGES = [ :updated, :published ]

    initiaize_with :client_name, :transport
    default_value_of :transport, Marples::NullTransport.instance

    # m = Marples::Client.new "publisher", stomp_client
    # m.updated publication
    # # => /topic/publications.updated
    #     { 'publication' => { 'id' => 12345, 'title' => '...', ... }}
    #
    def method_missing message, *args
      return super unless MESSAGES.include? message
      return super unless args.size == 1
      publish message, args[0].to_json
    end

    def publish message, data
      destination = "/topic/#{client_name}/#{message}"
      transport.publish destination, data
    end
    private :publish
  end
end
