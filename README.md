= hot-like-sauce

This is some sweet code for ActiveRecord (rails) that will allow you to obscure database fields. The data will always be obscured in the database, but can be read as plaintext or obscured. This is useful for admin views where you can display obscured data for people who shouldn't be seeing it.

== Usage

```ruby
gem 'hot_like_sauce'
```

```ruby
class Post < ActiveRecord::Base
  attr_obscurable :body
end
```

By default, when you read the value you get the original plain text.

```ruby
p = Post.create(:body => "readable text")
p.body
#=> "readable text"

Post.obscure_read_on_fields!(:body)
p.body
#=> "էu??+]?S???^Vx????gzq?'?"
```

`Post.obscure_read_on_fields!` can be called with no arguments to set all attr_obscurable fields. The inverse method is `Post.unobscure_read_on_fields!`

== Configuration

```ruby
HotLikeSauce.secret_key = "this-should-be-long-and-random"

HotLikeSauce.crypto_method = "aes-256-cbc" # default's to aes-256-cbc
```

== Contributing to hot-like-sauce

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2012 Justin Derrek Van Eaton. See LICENSE.txt for
further details.

