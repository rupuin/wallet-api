require_relative '../config/environment'

Handler = Proc.new do |request, response|
  # Build Rack environment from Vercel request
  env = {
    'REQUEST_METHOD' => request.request_method,
    'PATH_INFO' => request.path,
    'QUERY_STRING' => request.query_string || '',
    'SCRIPT_NAME' => '',
    'SERVER_NAME' => request.host,
    'SERVER_PORT' => request.port.to_s,
    'rack.version' => Rack::VERSION,
    'rack.url_scheme' => 'https',
    'rack.input' => StringIO.new(request.body || ''),
    'rack.errors' => $stderr,
    'rack.multithread' => false,
    'rack.multiprocess' => true,
    'rack.run_once' => false
  }

  # Add HTTP headers
  request.header.each do |key, value|
    env_key = "HTTP_#{key.upcase.gsub('-', '_')}"
    env[env_key] = value.join(', ') if value.is_a?(Array)
  end

  # Call Rails application
  status, headers, body = Rails.application.call(env)

  # Set response
  response.status = status
  headers.each { |k, v| response[k] = v }
  response.body = body.respond_to?(:join) ? body.join : body.to_s
end
