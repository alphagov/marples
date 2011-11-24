module Rails
  def self.logger
    NullLogger.instance # because Marples::ModelActionBroadcast.included calls Rails.logger
  end
end
