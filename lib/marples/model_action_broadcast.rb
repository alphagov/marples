module Marples
  module ModelActionBroadcast
    TRANSACTION_ACTIONS = :create, :update, :destroy
    CALLBACKS = TRANSACTION_ACTIONS + [:save, :commit]

    def self.included base
      base.class_eval do
        # Something that response to #subscribe and #publish - although we
        # only use #publish in this mixin.
        class_attribute :marples_transport
        # You *will* need to set this yourself in each application.
        class_attribute :marples_client_name
        # If you'd like the actions performed by Marples to be logged, set a
        # logger. By default this uses the NullLogger.
        class_attribute :marples_logger
        self.marples_logger = Rails.logger

        CALLBACKS.each do |callback|
          callback_action = callback.to_s =~ /e$/ ? "#{callback}d" : "#{callback}ed"
          after_callback = "after_#{callback}"
          next unless respond_to? after_callback

          notify = lambda { |record| record.class.marples_client.send callback_action, record }
          if TRANSACTION_ACTIONS.include?(callback) && respond_to?(:after_commit)
            after_commit :on => callback, &notify
          else
            send after_callback, &notify
          end
        end

        def self.marples_client
          @marples_client ||= build_marples_client
        end

        def self.build_marples_client
          Marples::Client.new transport: marples_transport,
            client_name: marples_client_name, logger: marples_logger
        end
      end
    end
  end
end
