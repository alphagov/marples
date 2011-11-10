module Marples
  class Client
    include Pethau::InitializeWith
    include Pethau::DefaultValueOf

    initialize_with :transport, :client_name, :logger
    default_value_of :client_name, File.basename($0)
    default_value_of :transport, Marples::NullTransport.instance
    default_value_of :logger, NullLogger.instance

    def join
      transport.join
    end

    def method_missing action, *args
      return super unless args.size == 1
      publish action, args[0]
    end

    def when application, object_type, action
      logger.debug "Listening for #{application} notifiying us of #{object_type} #{action}"
      destination = destination_for application, object_type, action
      logger.debug "Underlying destination is #{destination}"
      transport.subscribe destination do |message|
        logger.debug "Received message #{message.headers['message-id']} from #{destination}"
        logger.debug "Message body: #{message.body}"
        hash = Hash.from_xml message.body
        logger.debug "Constructed hash: #{hash.inspect}"
        attributes = hash.values[0]
        logger.debug "Yielding hash: #{attributes.inspect}"
        yield attributes
        logger.debug "Finished processing message #{message.headers['message-id']}"
      end
    end

    def publish action, object
      object_type = object.class.name.tableize
      destination = destination_for object_type, action
      logger.debug "Using transport #{transport}"
      logger.debug "Sending XML to #{destination}"
      logger.debug "XML: #{object.to_xml}"
      transport.publish destination, object.to_xml
      logger.debug "Message sent"
    end
    private :publish

    def destination_for application_name = client_name, object_type, action
      "/topic/marples.#{application_name}.#{object_type}.#{action}"
    end
    private :destination_for
  end
end
