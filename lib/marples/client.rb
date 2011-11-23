module Marples
  class Client
    [ :transport, :client_name, :logger ].each do |attribute|
      attr_accessor attribute
      private "#{attribute}=", attribute
    end

   def initialize *args
     if args[0].kind_of? Hash
       self.transport = options[:transport]
       self.client_name = options[:client_name]
       self.logger = options[:logger]
     else
       self.transport = args.shift
       self.client_name = args.shift
       self.logger = args.shift
     end
     raise "You must provide a transport" if transport.nil?
     self.client_name ||= File.basename($0)
     self.logger ||= NullLogger.instance
   end

    def join
      logger.debug "Listening on #{transport}"
      transport.join
    end

    def method_missing action, *args
      return super unless args.size == 1
      publish action, args[0]
    end

    def when application, object_type, action
      logger.debug "Listening for #{application} notifiying us of #{action} #{object_type}"
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
