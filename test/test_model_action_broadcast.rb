require 'test/unit'
require 'marples'
require 'marples/model_action_broadcast'
require 'active_record'

require 'support/rails'
require 'support/notifications'
require 'support/widget'

class TestModelActionBroadcast < Test::Unit::TestCase
  def setup
    ActiveRecord::Base.establish_connection :adapter => :nulldb
    ActiveRecord::Schema.define do
      create_table :widgets
    end

    Widget.marples_transport = FakeTransport.instance
    Widget.marples_client_name = 'widgetotron'

    FakeTransport.instance.flush
  end

  def test_created_notification_is_sent_on_create
    assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.created'
    Widget.create!
    assert_not_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.created'
  end

  def test_updated_notification_is_sent_on_update
    widget = Widget.create!

    assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.updated'
    widget.save!
    assert_not_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.updated'
  end

  def test_destroyed_notification_is_sent_on_destroy
    widget = Widget.create!

    assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.destroyed'
    widget.destroy
    assert_not_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.destroyed'
  end

  def test_created_notification_is_sent_after_commit
    Widget.transaction do
      assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.created'
      Widget.create!
      assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.created'
    end

    assert_not_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.created'
  end

  def test_updated_notification_is_sent_after_commit
    widget = Widget.create!

    Widget.transaction do
      assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.updated'
      widget.save!
      assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.updated'
    end

    assert_not_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.updated'
  end

  def test_destroyed_notification_is_sent_after_commit
    widget = Widget.create!

    Widget.transaction do
      assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.destroyed'
      widget.destroy
      assert_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.destroyed'
    end

    assert_not_nil latest_notification_with_destination '/topic/marples.widgetotron.widgets.destroyed'
  end
end
