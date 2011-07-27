# Buddy

Buddy is a lightweight Facebook library for Rails 3.

## Overview

* Support for iFrame Apps
* Uses signed\_request parameters for authentication
* Supports the Graph API and old REST API
* Fully compatible with **Rails 3** and **Ruby 1.9.2**

## Install

Add the following to your Gemfile

    gem 'buddy'

or for the latest Git version

    gem 'buddy', :git => 'git://github.com/buddybrand/buddy.git'

Generate and edit config/buddy.yml

    rails generate buddy_config

## Usage

Buddy adds all parameters contained in _signed\_request_ to the params[:fb] hash. See [Canvas Authentication](http://developers.facebook.com/docs/authentication/canvas)

To require the user to install the application add this to your ApplicationController:

    before_filter :ensure_application_is_installed

If the user authorized the application you can do API calls like this:

    # Publish to Graph API:
    facebook_session.post('/me/feed', :message => 'Hi there!')

    # Reading from Graph API:
    facebook_session.get('/me')

    # REST API
    facebook_session.call('users.getInfo')


## Todo

* Add tests
* Add some examples

## License

released under the **MIT license**

Copyright (c) 2011:

* Ole Riesenberg

Some concepts and code adapted from [Facebooker](http://github.com/mmangino/facebooker)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
