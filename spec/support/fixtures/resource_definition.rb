require 'datapimp/dsl'

# The motivation for the datapimp/dsl is to provide a DSL which will
# provide the base setup of our JSON API.  All of the behaviors can be
# modified by writing code for the appropriate class that governs that behavior:
#
# For resources:
#
# Commands
# Queries
# Serializers
# Policies
#
# This DSL will also generate a basic integration test suite against the defined
# API, along with some JSON API Documentation that can be played with in real time
# using the test view.

# API level config applies for the whole API. Here is where we define the policies which
# determine the access / authorization paramters for the user making the request to the API.

api "My books application" do
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
