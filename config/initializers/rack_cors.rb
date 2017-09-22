Rails.configuration.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %w[
      http://localhost:5000
      https://www.headlinesmasher.com
      http://www.headlinesmasher.com
      https://headlinesmasher.com
      http://headlinesmasher.com
    ]
    resource '/assets/*'
  end
end
