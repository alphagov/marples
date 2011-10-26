module Marples
  class Client
    include Pethau::InitializeWith
    include Pethau::DefaultValueOf

    MESSAGES = [ :updated, :published ]

    initialize_with :transport, :client_name, :logger
    default_value_of :client_name, File.basename($0)
    default_value_of :transport, Marples::NullTransport.instance
    default_value_of :logger, NullLogger.instance

    def method_missing message, *args
      return super unless MESSAGES.include? message
      return super unless args.size == 1
      publish message, args[0]
    end

    def when application, object_type, action
      transport.subscribe destination do |message|
        logger.debug "Received message #{message.headers['message-id']} from #{destination}"
        logger.debug "Message body: #{message.body}"
        hash = Hash.from_xml message.body
        attributes = hash.values_at hash.keys.first
        yield attributes
        logger.debug "Finished processing message #{message.headers['message-id']}"
      end
    end

    def publish message, object
      object_type = object.class.name.tableize
      destination = destination_for message, object_type
      logger.debug "Sending XML to #{destination}"
      logger.debug "XML: #{object.to_xml}"
      transport.publish destination, object.to_xml
      logger.debug "Message sent"
    end
    private :publish

    def destination_for message, object_type
      "/topic/#{client_name}.#{object_type}.#{message}"
    end
    private :destination_for
  end
end
