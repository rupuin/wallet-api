require_relative '../config/environment'
require 'stringio'
require 'benchmark'

Handler = Proc.new do |request, response|
  start_time = Time.now
  puts "=== REQUEST START at #{start_time} ==="

  begin
    # Build Rack environment
    env_build_time = Benchmark.realtime do
      @env = build_rack_env(request)
    end
    puts "Environment built in #{env_build_time}s"

    # Call Rails with detailed timing
    rails_time = Benchmark.realtime do
      @status, @headers, @body = Rails.application.call(@env)
    end
    puts "Rails processed in #{rails_time}s"

    # Set response
    response.status = @status
    @headers.each { |k, v| response[k] = v unless k.downcase == 'transfer-encoding' }

    # Handle body
    body_time = Benchmark.realtime do
      body_content = []
      @body.each { |chunk| body_content << chunk }
      response.body = body_content.join
      @body.close if @body.respond_to?(:close)
    end
    puts "Body processed in #{body_time}s"

    total_time = Time.now - start_time
    puts "=== TOTAL TIME: #{total_time}s ==="

  rescue => e
    puts "ERROR: #{e.class} - #{e.message}"
    puts e.backtrace.first(10).join("\n")

    response.status = 500
    response['Content-Type'] = 'application/json'
    response.body = {
      error: 'Internal Server Error',
      message: e.message,
      time_elapsed: Time.now - start_time
    }.to_json
  end
end

def build_rack_env(request)
  body_content = request.body.to_s

  env = {
    'REQUEST_METHOD' => request.request_method,
    'PATH_INFO' => request.path,
    'QUERY_STRING' => request.query_string || '',
    'SCRIPT_NAME' => '',
    'SERVER_NAME' => request.host,
    'SERVER_PORT' => request.port.to_s,
    'rack.version' => Rack::VERSION,
    'rack.url_scheme' => 'https',
    'rack.input' => StringIO.new(body_content),
    'rack.errors' => $stderr,
    'rack.multithread' => false,
    'rack.multiprocess' => true,
    'rack.run_once' => false
  }

  # Copy headers
  request.header.each do |key, values|
    env_key = "HTTP_#{key.upcase.gsub('-', '_')}"
    env[env_key] = values.is_a?(Array) ? values.first : values.to_s
  end

  # Set Content-Type and Content-Length
  if request.header['content-type']
    env['CONTENT_TYPE'] = request.header['content-type'].first
  end

  env['CONTENT_LENGTH'] = body_content.bytesize.to_s

  env
end
