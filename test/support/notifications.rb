class FakeTransport
  include Singleton

  attr_reader :notifications

  def initialize
    flush
  end

  def flush
    self.notifications = []
  end

  def publish(destination, message, headers = {})
    notifications << { destination: destination, message: Hash.from_xml(message), headers: headers }
  end

  private
    attr_writer :notifications
end

def flush_notifications
  FakeTransport.instance.flush
end

def latest_notification_with_destination(destination)
  notifications = FakeTransport.instance.notifications
  notifications.reverse.detect { |n| n[:destination] == destination }
end
