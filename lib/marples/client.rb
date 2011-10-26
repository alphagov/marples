module Marples
  class Client
    MESSAGES = [ :updated, :published ]

    initiaize_with :transport, :client_name
    default_value_of :client_name, File.basename($0)
    default_value_of :transport, Marples::NullTransport.instance

    def method_missing message, *args
      return super unless MESSAGES.include? message
      return super unless args.size == 1
      publish message, args[0]
    end

    def when application, object_type, action
      transport.subscribe destination do |message|
        hash = Hash.from_xml message.body
        attributes = hash.values_at hash.keys.first
        yield attributes
      end
    end

    def publish message, object
      object_type = object.class.name.tableize
      destination = destination_for message, object_type
      transport.publish destination, object.to_xml
    end
    private :publish

    def destination_for message, object_type
      "/topic/#{client_name}.#{object_type}.#{message}"
    end
    private :destination_for
  end
end
