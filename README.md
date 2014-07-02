### Data driven API programming  

This gem promotes a declarative style of developing JSON APIs that automates a lot of common patterns
found in the development of systems which have multiple users, with multiple roles and permissions. 

An API is a collection of resources, and resources can be queried, or commands can be run against resources, each by certain users in certain ways depending on the user's authorization level.  

The DSL provided by this gem allows you to accomplish the tasks of writing your API documentation, your integration tests, as well as your actual implementation code at the same time, and in such a way that exposes metadata. 

Because the API exposes metadata about the resources it contains, their schemas, and the various policies and details about them, it is possible for API client libraries to configure themselves accordingly.  

### Example

```ruby
  require 'datapimp/dsl'

  api :my_app => "My Application" do
    version :v1

    desc "Public users include anyone with access to the URL"
    policy :public_users do
      allow :books, :commands => false, :queries => true
    end

    desc "Authenticated users register and are given an auth token"
    policy :logged_in_users do
      authenticate_with :header => 'X-AUTH-TOKEN', :param => :auth_token
      allow :books, :commands => true, :queries => true
    end

    desc "Admin users have the admin flag set to true"
    policy :admin_users do
      extends :logged_in_users
      test :admin?
    end
  end
```

An API can be inspected:

```ruby
api("My Application").authentication_header #=> "X-AUTH-TOKEN"
api("My Application").policies #=> [:public_users, :logged_in_users, :admin_users]
api("My Application").policy(:admin_users).resource(:books).allowed_commands #=> [:create, :update, :delete]
```

An API is made up of resources:

```ruby
  resource "Books" do
    serializer do
      desc "A unique id for the book", :type => :integer
      attribute :id

      desc "The title of the book", :type => :string
      attribute :title

      desc "The year the book was published", :type => :integer
      attribute :year

      desc "A reference to the author", :type => "Author"
      has_one :author
    end

    command :update, "Update a book's attributes" do
      # Will ensure the command is run with
      # Book.accessible_to(current_user).find(id).
      scope :accessible_to

      params do
        duck :id, :method => :to_s

        optional do
          string :title
        end
      end
    end

    query do
      start_from :scope => :accessible_to

      params do
        desc "The year the book was published (example: YYYY)"
        integer :year_published
      end

      role :admin do
        start_from :scope => :all
      end
    end
  end
```

A resource can also be inspected:

```ruby
meta_data = api("My Application").resource("Books").meta_data

meta_data.attributes # {:id => "The id of the book", :year_published => "The year it was published"}
meta_data.commands => [:update]
meta_data.command(:update).arguments #=> [:id, :year, :title]
meta_data.command(:update).optional_arguments #=> [:year, :title]
```

This inspection goes a long way to some advanced features, such as
automated documentation and integration test generation, or in writing
tools for generating client libraries and the like.

### Customizing the elements

How are each of these behaviors is stored in code? In a way that will be
very familiar to Rails developers, following common naming conventions
and file organization patterns.

```
- app
  - commands
    - application_command.rb
    - create_book.rb
    - update_book.rb
  - contexts
    - application_context.rb
    - book_context.rb
  - serializers
    - book_serializer.rb
```

### Request Context: Current User, Resource, and REST 

From the programmer's perspective, a typical resource is made up of several request patterns:

- Filter Context (index, show)
- Commands (aka mutations. create, update, destroy)
- Serializers (aka presenters, views) 

Each of these objects can be configured to behave in certain ways that may be dependent on the user or role making the request to interact with them.

Most API requests can be thought of in the following ways:

```ruby
# A Typical read request ( query / filter or detail view )

response = present( this_resource )      # resource -> filter context
            .to(this_user)               # filter context: relevant for this user
            .in(this_presentation)       # serializer: different slices / renderings

response.cache_key                       # russian doll style / max-updated-at friendly
response.etag                            # http client conditional get
```

The filter context and serializer classes make this easy.  They also
make writing -- or rather, generating -- documentation and tests very
easy as well.

```ruby
# Typical mutation request ( create, update, delete )

outcome = run(this_command)
            .as(this_user)
            .against(this_set_of_one_or_more_records)
            .with(these_arguments)

outcome.success? 

outcome.error_messages

outcome.result
```

The command class determines the specifics of the above style of
request.

### The Filter Context

The filter context system is used to standardize the way we write
typical index and show actions in a typical Rails app. A user is
requesting to view a set of records, or an individual records.

Given a user making a request to view a specific resource, we arrive at
the 'filter context'.  The filter context is responsible for 'scoping' a
resource to the set of records that user is permitted to view.  

Based on the combination of parameters used to build that filter, we
compute a cache key that simplifies the process of server caching and
http client caching at the same time.

The filter context itself and the available parameters and their allowed
values are specified by the DSL, which simplifies the process of writing
complex queries and also provides configuration meta-data that aids in
the process of developing client user interfaces, API documentation, and
test code.

### Commands

The command class allows you to declare the available parameters, the
required values, their data types, etc.  It also allows you to declare
which users can run the command, and further restrict the parameters
allowed and the values they accept.

### Serializers 

- ActiveModel Serializers
- Documentation DSL
- Metadata for inspection + documentation generation

## API Documentation & Integration Tests

- rspec_api_documentation gem
- plan: take advantage of metadata defined above to auto-generate
  documentation with the ability to pass expectation blocks as pass /
  fail indicators
