# Block Chain Explorer for altcoins

Block Chain Explorer for altcoins. Works as stand-alone application for a one coin project. See Usage section.

Extracted from BCE project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bce-explorer', github: 'madzebra/bce-explorer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bce-explorer

## Usage

Simple application example

```ruby
# config.ru
require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'bce-explorer'

COIN_CONFIG = <<EOF
Name: "RosCoin"
Tag: "ROS"
Algorithm: "X11 (PoW) + Proof of Stake"
BitcoinTalk: "https://bitcointalk.org/index.php?topic=810437.0"
GitHub: "https://github.com/roscoin1/roscoin"
Website: "http://www.roscoin.com"
Twitter: "https://twitter.com/roscoin"
_rpc_host: "127.0.0.1"
_rpc_port: "19092"
_rpc_user: "Roscoinrpc"
_rpc_pass: "Roscoinpass"
EOF

BceExplorer::Env.root = File.expand_path '.', File.dirname(__FILE__)
coin = BceExplorer::Configuration.new YAML.load(COIN_CONFIG)

run BceExplorer::App.new coin
```

## Contributing

1. Fork it ( https://github.com/madzebra/bce-explorer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
