# Ruboty::Jobcan

## Usage

```
# Set up
ruboty remember my jobcan code <code>
ruboty remember my jobcan group id <group_id>

# Clock in/out
ruboty punch the clock
ruboty punch in
ruboty punch out
```

`<code>` is the text attached to your mobile login URL,
e.g. `http://jobcan.jp/m?code=YOUR_CODE_GOES_HERE`.
Check out the invitation mail from JOBCAN for the URL.

`<group_id>` is the numeric ID of your group;
ask your manager or check out the source code of https://ssl.jobcan.jp/employee for it.

![group ID](img/group_id.png)

## Installation


```ruby
gem 'ruboty-jobcan'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruboty-jobcan

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/uasi/ruboty-jobcan.

