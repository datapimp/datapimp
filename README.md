### Data driven API programming  

This gem promotes a declarative style of developing JSON APIs that automates a lot of common patterns
found in the development of systems which have multiple users, with multiple roles and permissions. 

An API is a collection of resources, and resources can be queried, or commands can be run against resources, each by certain users in certain ways depending on the user's authorization level.  

The DSL provided by this gem allows you to accomplish the tasks of writing your API documentation, your integration tests, as well as your actual implementation code at the same time, and in such a way that exposes metadata. 

Because the API exposes metadata about the resources it contains, their schemas, and the various policies and details about them, it is possible for API client libraries to configure themselves accordingly.  

### Example

```ruby
  require 'datapimp/dsl'

  # Motivation
  #
  # The motivation for the datapimp/dsl is to provide a DSL which will allow for
  # data-driven configuration for APIs and the various endpoints they provide.
  #
  # All of the behaviors can be modified by writing code for the appropriate class that governs that behavior,
  # otherwise, the default out of the box behaviors will be assumed where possible.
  #
  # For resources:
  #
  # Commands:
  #   Commands specify the inputs / filters for the parameters
  #   that get passed in the request to CREATE / UPDATE / DESTROY actions.
  #
  #   Commands expose a method called 'execute' which can be overridden for
  #   specific behavior.
  #
  # Queries:
  #   Queries govern the behavior of READ requests ( either for the whole resource or an individual object )
  #   for different policies ( public users, admins, etc )
  #
  # Serializers:
  #   Serializers ( based on ActiveModel::Serializers ) specify the fields, their data types, asssocations, etc.
  #   Each resource can have one or many serializers.  Serializers govern how an object is serialized for the user
  #   making the request.
  #
  # Policies:
  #   Policies govern who can do what against a given resource.
  #
  # Documentation / Examples:
  #
  # This DSL will also generate a basic integration test suite against the defined
  # API, along with some JSON API Documentation that can be played with in real time
  # using the test view.


  # ---- BEGIN SAMPLE CODE --------

  api :my_app => "My Application" do
    version :v1

    desc "Public users include anyone with access to the URL"
    policy :public_users do

      # commands / queries can be set to true or false to allow
      # all commands and queries defined for the books resource.
      allow :books, :commands => false, :queries => true

      # we can also pass an array of queries or commands
      # allow :books, :commands => [:like]
    end

    desc "Authenticated users register and are given an auth token"
    policy :logged_in_users do
      authenticate_with :header => 'X-AUTH-TOKEN', :param => :auth_token
      allow :books, :commands => true, :queries => true
    end

    desc "Admin users have the admin flag set to true"
    policy :admin_users do
      same_as :logged_in_users

      # what method should we call on the current_user to see if
      # it is eligible for this policy?
      test :admin?

      # an alternative.  checks to see if the method 'role' returns 'admin'
      # test :role => "admin"
    end
  end



  # This is an example of the Datapimp resource definition DSL.
  #
  # It will define:
  #
  # BookSerializer < ApplicationSerializer
  # CreateBook < ApplicationCommand
  # UpdateBook < ApplicationCommand
  # BookQuery < ApplicationQuery

  # This can either all be put in a single file
  # or any file can open up the books resource defintion
  resource "Books" do
    serializer do
      desc "A unique id for the book", :type => :integer
      attribute :id

      desc "The title of the book", :type => :string
      attribute :title
    end

    # This will create a class 'UpdateBook'.  The execute method
    # is open for definition by the developer.
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

    command :create, "Add a new book to the library" do
      scope :accessible_to

      params do
        string :title
      end
    end

    command :like, 'Toggle liking on/off for a book' do
      scope :all

      params do
        duck :id, :method => :to_s

        optional do
          desc "You can manually pass true or false.  If you leave it off, it will toggle the liking status"
          boolean :like, :discard_empty => true
        end
      end
    end

    # This will create a class 'BookQuery'.  The build_scope method
    # is open for definition by the developer.
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

    # Each resource will be mounted by the API under a base path
    # such as /api/v1.  So the routes defined here would be available
    # under /api/v1/books, /api/v1/books/1 etc
    routes do
      get "/books", :to => :query
      show "/books/:id", :to => :show
      post "/books", :to => :create
      put "/books/:id", :to => :update
      put "/books/:id/like", :to => :like
    end

    examples :client => :rest do
      setup_data do
        let(:books) do
          3.times.map { |n| create(:book, title: "Book #{ n }") }
        end
      end

      with_profile :public_user do
        example "Listing all of the books", :route => :query
        example "Viewing a single book", :route => :show
      end
    end

  end
```

As you can see, the above DSL allows you to configure large chunks of
typical API behaviors.  

How are each of these behaviors is stored in code?

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
