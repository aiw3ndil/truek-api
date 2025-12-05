# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Production configuration
  allow do
    origins 'https://www.truek.xyz', 
            'https://truek.xyz'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: true,
      max_age: 86400  # Cache preflight requests for 24 hours
  end

  # Development configuration
  if Rails.env.development? || Rails.env.test?
    allow do
      origins 'http://localhost:3000', 
              'http://localhost:5173',  # Vite default
              'http://localhost:4173',  # Vite preview
              'http://127.0.0.1:3000',
              'http://127.0.0.1:5173',
              'http://127.0.0.1:4173'

      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        expose: ['Authorization']
    end
  end
end
