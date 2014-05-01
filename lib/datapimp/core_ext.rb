if defined?(::Mutations) && defined?(::Rails) && Rails.env.development?
  Mutations.cache_constants = false
end
