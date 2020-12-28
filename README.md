# CmAdmin

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/cm_admin`. To experiment with that code, run `bin/console` for an interactive prompt.

First create a new rails project with the following command. If you are adding to existing project skip this

```
rails new blog -m https://raw.githubusercontent.com/commutatus/cm-rails-template/devise_integration/template.rb
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cm_admin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cm_admin

Assuming we have a model created already or we can create one

    $ rails g user first_name:string last_name:string


## Usage

For copying layout such as CSS and the layout files

    $ rails g cm_admin:install

For generating the index page views

    $ rails g cm_admin:view products index title description

For generating the show page views

    $ rails g cm_admin:view products show title description

For generating the form page views
    $ rails g cm_admin:view products form column_name:field_type
    $ rails g cm_admin:view products form title:string description:string

Following field types are acceted

* input-integer
* input-string
* single-select
* multi-select
* checkbox
* radio

## Usage

For demo check [here](http://cm-admin.labs.commutatus.com/admin/users/)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/commutatus/cm-admin. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CmAdmin project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cm-admin/blob/master/CODE_OF_CONDUCT.md).
