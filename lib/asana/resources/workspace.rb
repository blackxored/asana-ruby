require 'pry'
module Asana
  class Workspace < Asana::Resource
    def create_task(options = {})
      options.merge!(assignee: 'me') unless options[:assignee] or options['assignee']
      options.merge!(workspace: self.id)

      post_body = { data: options }
      response = Task.post(nil, nil, post_body.to_json)
      hash = connection.format.decode(response.body)

      Task.find hash["id"]
    rescue Exception => e
      $stderr.puts "ERROR: #{e.message}"
      $stderr.puts "RESPONSE: #{e.response.body}" if e.respond_to?(:response)
    end

    # From API docs: If you specify a workspace you must also specify an assignee to filter on.
    def tasks(options = {})
      options.merge!(assignee: 'me') unless options[:assignee] or options['assignee']

      get("tasks?assignee=#{options[:assignee]}").map{|h| Asana::Task.find h["id"]}
    rescue Exception => e
      $stderr.puts "ERROR: #{e.message}"
      $stderr.puts "RESPONSE: #{e.response.body}" if e.respond_to?(:response)
    end

    def create_tag(options = {})
      response = post("tags", nil, {data: options}.to_json)
      Asana::Tag.new(connection.format.decode(response.body))
    end

    def tags
      get(:tags).map{|h| Asana::Tag.find h["id"]}
    end
  end
end
