# CmAdmin

New CmAdmin gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cm-admin'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cm-admin

## Usage

Install the gem

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

Bug reports and pull requests are welcome on [GitHub](https://github.com/commutatus/cm-admin).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
