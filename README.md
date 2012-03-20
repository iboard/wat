WAT (WebApplicationTemplate)
============================

WAT is derived from RailsApp/templates by [Daniel Kehoe](https://github.com/DanielKehoe)

Featuring
---------

  * MongoDB / MongoID
  * OmniAuth
  * HAML
  * Based on Rails 3.2.2
  * TTD with RSpec
  * Twitter Bootstrap

_see:_

  * [GitHub/RailsApps](https://github.com/RailsApps/rails3-application-templates)
  * [WAT](https://github.com/iboard/wat)


    THIS PROJECT IS FOR TESTING PURPOSES ONLY (YET)
    YOU MAY USE IT AS A STARTER APP FOR YOUR APPLICATION
    BUT DON'T USE IT IN PRODUCTION AS IT IS AT THE MOMENT!

Things done after generating the app from the template
------------------------------------------------------

  * Modified: application.css
  * Add:      Menu in nav-bar with home-button
  * Modified: the behavior of omniauth-twiter and user-model to use name as a mongo-key
  * Add:      omniauth for Facebook, Google, Identity, LinkedIn, OpenID, 37signals
  * Added:    Some specs
  * Added:    Twitter bootstrap
  * Modified: User can have more authentications
  * Added:    Spork support. Rake always runs with --drb
  * Added:    Foursquare Authentication
  * More:     Bootstraping
  * Added:    Tumblr Authentication
  * Added:    Facilities (see below)
  * Added:    I18n for :en and :de
  * Added:    Model `Page`
  * Added:    Confirm registraton mail


Installation
============

  1. Install [mongodb](http://mongodb.org) and [rvm](http://beginrescueend.com/rvm/install/)
  2. Clone or fork this project from [Github](http://github.com/iboard/wat)
  3. copy config/test_secrets.yml to config/secrets.yml and 
    * Enter your API-Keys
    * Disable services you don't want by remarking it.
  4. copy config/settings/*yml_sample to *yml and edit development.yml and production.yml
    * DO NOT EDIT test.yml!
  5. bundle
  6. Run `bundle execute guard`

API-Keys
--------

  If you don't have API-Keys for various providers, you'll find them on the provider's websites

  * [Twitter](https://dev.twitter.com/apps )
  * [Facebook](https://developers.facebook.com/apps)
  * [Google](https://code.google.com/apis/console/)
  * [Foursquare](https://foursquare.com/oauth/)
  * [LinkedIn](https://www.linkedin.com/secure/developer)
  * [Tumblr](http://www.tumblr.com/oauth/apps)

Models
======
    
The 'Facility-Idea'
-------------------

A facility has a name (like 'Admin', 'Author') and an access-mask like in the unix-filesystem (rwx)
Facilities are embedded to the user and helper-functions like _can_execute?('Admin')_ will return true or false if the user has this facility.

Next step will be: Models like 'Page' will embed Facilities too in order to support code like this:

```ruby
  @page.facilities.create(name: 'user one', access: 'rw-')
  if current_user.can_write_on?(@page)
    ...
  end
```

Model Page
----------

* A page has a _parmalink_ which is used as a key -> http://..../permalink
* Title and body can be translated using mongoID `:localize => true`
* Use permalink 'hero' for the "Hero-Page" displayed at the root-path
* Begin permalink with @ will make a page "featured" and displays the page below the hero-page at the root_path.
* Create a page in any language. Save it. Switch language (at the bottom of the screen). Edit the page and translate it.
* Create one page permalinked as 'README' or remove the menu-item from `views/layout/application.haml`


License
=======

Public Domain Dedication
------------------------

This work is a compilation and derivation from other previously released works. With the exception of 
various included works, which may be restricted by other licenses, the author or authors of this code 
dedicate any and all copyright interest in this code to the public domain. We make this dedication for 
the benefit of the public at large and to the detriment of our heirs and successors. We intend this 
dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this 
code under copyright law.

Running Demo
============

There is a running installation at [andi.altendorfer.at](http://andi.altendorfer.at)
