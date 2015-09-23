# Block Chain Explorer for altcoins

Block Chain Explorer for altcoins.

## Installation

    $ git clone https://github.com/madzebra/bce-explorer.git
    $ cd bce-explorer
    $ bundle
    $ cp config/coins/coin.yml.example config/coins/ros.yml
    $ vim config/coins/ros.yml
    $ ./server start


## Usage

config for nginx

```
upstream bce-explorer {
  server unix:/tmp/thin.0.sock;
}

server {
  listen   80;
  server_name bce.madzebra.co;

  location ~ \.(png|css|ico|jpg|gif|txt) {
    root /opt/bce-explorer/public; # FIXME if you have another path
    access_log off;
  }

  location / {
    proxy_pass http://bce-explorer;
    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  Host $http_host;
  }
}
```

## Dependency

* ruby 2.2 (was tested with 2.2)
* mongodb (db storage for wallets)
* redis (cache server)

## Contributing

1. Fork it ( https://github.com/madzebra/bce-explorer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
