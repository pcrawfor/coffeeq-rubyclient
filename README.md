# CoffeeQ Ruby Client - Ruby client code for interacting with redis backed node.js queue

CoffeeQ is a simple queueing library for node.js implemented on top of redis and inspired by resque.  The ruby client is a small class which provides the ability to enqueue and dequeue items to the queue backend via redis allowing ruby code to interact with the node.js queue.

## Usage
    
    require 'coffeeq_client'
    client = CoffeeQClient.new
    client.enqueue "events", "addPoints", ["Paul", 100, Time.now.utc]
    
The coffeeq client provides two functions for interacting with the queue the `enqueue` function allows you to add a call to the coffeeq queue. 

`enqueue` takes as it's parameters: `queue name, function name, arguments array`.  

The function that you pass through here must be defined as a job by the coffeeq worker code which will be processing the queue (see [https://github.com/pcrawfor/coffeeq](https://github.com/pcrawfor/coffeeq) readme for details).

The client also provides a dequeue function which will pull an item off a redis queue and execute an associated block upon execution this allows you to do things like push items onto a queue to pass values from the node.js queueing system back to a ruby process.

    require 'coffeeq_client'
    client = CoffeeQClient.new
    client.dequeue("processed") { |item| puts "got processed item off queue #{item}"}

