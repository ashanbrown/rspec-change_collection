# RSpec::ChangeCollection [![Build Status](https://travis-ci.org/dontfidget/rspec-change_collection.png)](https://travis-ci.org/dontfidget/rspec-change_collection)

RSpec::ChangeCollection provides the `to_include` and `to_exclude` methods to the `change` for blocks that return a collection.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-change_collection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-change_collection

And require it as:

    require 'rspec/change_collection'

## Usage

Use the `to_include` and `to_exclude` methods to make assertions about the effect of an rspec `change` block.

Both `to_include` and `to_exclude` accept objects or blocks.  You can pass it a list of objects:

    array = []
    expect { array << 1 << 2 }.to change { array }.to_include 1, 2

And you can use block to make claims about any of the items before and after the change:

    array = [1]
    expect { array << 2 }.to change { array }.to_include(&:even?)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
