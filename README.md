# API Helpers

This is a collection of patterns that I incorporate when developing API
for rails apps.  It is meant to give a basic CRUD scaffold for free,
with naming conventions for defining classes to extend default behavior.

### Filter Contexts

FilterContexts are created when a specific user makes a GET request to
either a typical index or show action.  The FilterContext class is
responsible for building a query based on the parameters of the request,
and the user that is making it.

### Caching

FilterContexts are cacheable, and are based on the Russian Doll style
caching strategy which uses a timestamp based cache key that is 
is designed to work with Cache stores which use the LRU ( Least Recently Used )
method of expiration.

### Mutations

For REST endpoints that handle the C.UD of Rest we delegate to
subclasses of `Mutations::Command` which is provided by the mutations
gem.

### Example

```ruby
class Venue < ActiveRecord::Base
  include Datapimp;
  belongs_to :user
end

class VenueFilterContext < Datapimp::Filterable::Context
  def build_scope
    if !user.admin?
      self.scope = self.scope.where(user_id: user.id)
    end

    if user.admin? && params[:user_id]
      self.scope = self.scope.where(user_id: params[:user_id])  
    end
  end
end

# The default implementation
class CreateVenue < Mutations::Command
  required do
    model :user
    hash :params
  end

  def execute
    # do whatever
  end
end
```
