# Marples

A message destination arbiter.

  "Alfred Ernest Marples, Baron Marples PC (9 December 1907 – 6 July 1978) was
  a British Conservative politician who served as Postmaster General and
  Minister of Transport. Following his retirement from active politics in 1974,
  Marples was elevated to the peerage."
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
  # => /topic/publisher.publications.updated
      { 'guide' => { 'id' => 12345, 'title' => '...', ... }}

### Listening for messages

  stomp_client = Stomp::Client.new ...
  m = Marples::Client.new stomp_client
  m.when 'publisher', 'publication', 'updated' do |publication|
    puts publication['slug']
    # => "how-postcodes-work"
  end
