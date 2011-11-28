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
go to by enforcing a naming scheme, and means we don't care about which
transport representation is used, because these details are hidden from us.


## Usage

### Sending a message

    stomp = Stomp::Client.new ...
    m = Marples::Client.new transport: stomp, client_name: "publisher"
    m.updated publication
    # => /topic/marples.publisher.publications.updated

### Listening for messages

    stomp = Stomp::Client.new ...
    m = Marples::Client.new transport: stomp
    m.when 'publisher', 'publication', 'updated' do |publication|
      puts publication['slug']
      # => "how-postcodes-work"
    end
    m.join # Join the listening thread

### Adding more content to a message

Some objects are only useful with more information eg an Account object is maybe
only useful when it has a list of all customers as well.

It's possible that you could override `#to_xml` for each object, but that feels
a little messy.

Normally of course you'd use an implementation of
[Data Enricher](http://eaipatterns.com/DataEnricher.html) but if, for some
reason, you don't have anywhere to implement these integration patterns, you can
choose to implement your own message payload generator:

    stomp = Stomp::Client.new ...
    m = Marples::Client.new transport: stomp, client_name: "publisher"
    m.payload_for Account do |account|
      account.to_xml :include => :customers
    end

    account = Account.find ...
    m.updated account

Marples expects XML data to be put on the bus, if you choose to return something
that's not XML then you're on your own.


## Logging

You can inject your logger into Marples to get some debugging information.

    logger = Logger.new STDOUT
    logger.level = Logger::DEBUG
    producer = Marples::Client.new transport: stomp, client_name: "publisher",
      logger: logger
    ...
    consumer = Marples::Client.new transport: stomp, logger: logger


## ActiveModel(ish) integration

If you'd like to get broadcasts of ActiveModel object (or objects whose
classes behave a little like ActiveModel in terms of callbacks) you can
include `Marples::ModelActionCallback` which will attempt to hook into
`after_create`, `after_save`, `after_update`, `after_destroy` and
`after_commit` to broadcast these actions. If your class doesn't have these
methods available the action will be skipped with no error.

Use it like this:

    require 'marples/model_action_callback'
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


## Testing

You probably don't want to provide a broker to your test environment.

Marples provides `Marples::NullTransport` which you can use in place of your
real transport when you don't care what happens to the messages:

  null_transport = Marples::NullTransport.instance
  Marples::Client.new transport: null_transport, client_name: 'whatever'


## Semantic Versioning

To give you confidence when deciding which version of Marples to depend on we
will be using the Semantic Versioning scheme described at http://semver.org/.


## Licencing information

It's not adviseable to use code that's not had the terms of its licence made
explicit. This project is released under the MIT licence, a copy of which
should be distributed with this project in the LICENCE file.
