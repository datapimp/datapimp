# Check my style, son. 

This gem incorporates a series of approaches that I take whenever 
I am developing Rails apps.  It is designed to help you get
a RESTful JSON API very quickly once you have your data model figured out.

```ruby
# app/models/account.rb
class Accounts < ActiveModel::Base
  include Datapimp
end

# app/controllers/accounts_controller.rb
class AccountsController < ApplicationController
  include Datapimp
end

# config/routes.rb
resources :accounts
```

The above code will give you everything you need to have the RESTful routes
for your `Account` resource.  When you inevitably need to customize things,
then I believe the system I use is very intuitive and powerful.

## Filter Context 

The `ApplicationFilterContext` is a class that handles the `index` and `show`
actions for your resource, and it gives you a robust querying interface, as well
as server and http client caching out of the box.  The filter context is aware 
of who is querying the resource, and what parameters they are using.  

This will allow you to implement custom logic that dictates who can query what resources
using what parameters.

Every resource gets its own Filter Context for free, but when you want to customize:

```ruby
class AccountFilterContext < ApplicationFilterContext
  def user_is_admin?
    user.admin?
  end

  def build
    # ensure that a non-admin users query for any accounts they don't own
    self.scope = self.scope.owned_by(user) unless user_is_admin?
  end
end
```

Under the hood, what is happening is that when a user makes a request
to query the `Account` resource, our controller is doing:

```ruby
def index
  @accounts = Account.query(current_user, params)
  @accounts.class # => AccountFilterContext
  render(:json => @accounts)
end

def show
  @account = Account.query(current_user, params).find(params[:id])
  render :json => @account
end
```

When you want to customize the JSON output, the gem works very well with
`ActiveModel::Serializers` and even sets up default ones for you.

### Caching

One other nice benefit of the `ApplicationFilterContext` and its subclasses,
is you get smart server caching and HTTP Caching for free.  The caching and 
expiration strategy is based on the 'Russian Doll' caching technique popularized by @dhh.

In order to get the full benefit of this, it is advisable that you use a cache store
that handles expiration based on a least-recently-used (LRU) algorithm such as redis.

## Mutations

The way Create, Update, and Destroy actions are handled for us is by delegating to
subclasses of the `Datapimp::Command` class, which is based on the lovely `mutations` gem.

For the `Account` resource:

```ruby
class CreateAccount < Datapimp::Command
  required do
    model :user
    hash :account
  end
  
  def execute
    account = user.accounts.create(account)
    external_service.notify(acount)
  end
end
```

The benefit of the mutations pattern is best explained on the github page for the gem.
