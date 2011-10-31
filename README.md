# Marples

A message destination arbiter.

    "Alfred Ernest Marples, Baron Marples PC (9 December 1907 – 6 July 1978) was
    a British Conservative politician who served as Postmaster General and
    Minister of Transport. Following his retirement from active politics in
    1974, Marples was elevated to the peerage."
      -- http://en.wikipedia.org/wiki/Ernest_Marples

As Postmaster, Ernest Marples introduced postcodes to the UK, making message
routing easier.

Marples, this gem, removes any uncertainty about which destination our messages
go to by enforcing a naming scheme.


## Usage

### Sending a message

    stomp_client = Stomp::Client.new ...
    m = Marples::Client.new stomp_client, "publisher"
    m.updated publication
    # => /topic/marples.publisher.publications.updated
	{ 'guide' => { 'id' => 12345, 'title' => '...', ... }}

### Listening for messages

    stomp_client = Stomp::Client.new ...
    m = Marples::Client.new stomp_client
    m.when 'publisher', 'publication', 'updated' do |publication|
      puts publication['slug']
      # => "how-postcodes-work"
    end
    m.join # Join the listening thread


## Logging

You can inject your logger into Marples to get some debugging information.

    logger = Logger.new STDOUT
    logger.level = Logger::DEBUG
    producer = Marples::Client.new stomp_client, "publisher", logger
    ...
    consumer = Marples::Client.new stomp_client, 'consumer_name_here', logger


## ActiveModel(ish) integration

If you'd like to get broadcasts of ActiveModel object (or objects whose
classes behave a little like ActiveModel in terms of callbacks) you can
include `Marples::ModelActionCallback` which will attempt to hook into
`after_create`, `after_save`, `after_update`, `after_destroy` and
`after_commit` to broadcast these actions. If your class doesn't have these
methods available the action will be skipped with no error.

Use it like this:

    class Sandwich
      include Marples::ModelActionCallback
    end

    Sandwich.marples_transport = Stomp::Client.new 'stomp://localhost:61613'
    Sandwich.marples_client_name = 'menu'
    Sandwich.marples_logger = Logger.new(STDOUT)

The interesting things that happen to sandwiches will now be broadcast for
other applications to pick up on as desired. No need to do anything special,
just use the model like you normally would:

    s = Sandwich.new
    s.add_filling "cheese"
    s.add_filling "ham"
    s.save!
