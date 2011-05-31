require 'redis'
require 'json'

# CoffeeQClient
# ============
#
# Usage:
# require 'coffeeq_client'
# c = CoffeeQClient.new
# c.enqueue('queue1', 'add', [4,5])
# c.dequeue("queue1") { |msg| puts "got message #{msg}"}
#
# Client publishing:
# 1. push an item onto a queue 
# 2. send a pub sub message on the queue channel
# 
# Client working: 
# 1. subscribe to queue channel
# 2. on receipt of message pop item from queue
# 
class CoffeeQClient
  attr_accessor :client
    
  def initialize(host='localhost', port=6379)
    @host = host
    @port = port
    
    @pubsubClient = Redis.new(:host => @host, :port => @port)    
    @queueClient = Redis.new(:host => @host, :port => @port)
  end
  
  def enqueue(queue, func, args)
    puts "enqueue"
    val = {:class => func, :args => args}.to_json
    key = ":queue:#{queue}"
    puts "key #{key}"
    @queueClient.rpush key, val
    @pubsubClient.publish key, "queued" do
      puts "published"
    end
  end
  
  def dequeue(queue, &block)
    queue_channel = ":queue:#{queue}"
    trap(:INT) { puts; exit }
    
    @pubsubClient.subscribe(queue_channel) do |on|
      on.subscribe do |channel, subscriptions|
        puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
      end

      on.message do |channel, message|
        puts "##{channel}: #{message}"
        block.call(message)
      end

      on.unsubscribe do |channel, subscriptions|
        puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
      end
    end
  end  
end