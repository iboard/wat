WAT (WebApplicationTemplate)
============================

WAT is derived from RailsApp/templates by [Daniel Kehoe](https://github.com/DanielKehoe)

Featuring

  * MongoDB / MongoID
  * OmniAuth
  * HAML
  * Based on Rails 3.2.2

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


Installation
============

  1. Clone or fork this project from [Github](http://github.com/iboard/wat)
  2. copy config/test_secrets.yml to config/secrets.yml and 
    * Enter your API-Keys
    * Disable services you don't want by remarking it.
  3. bundle
  4. Run `bundle execute guard`

API-Keys
--------

  If you don't have API-Keys for various providers, you'll find them on the provider's websites

  * [Twitter](https://dev.twitter.com/apps )
  * [Facebook](https://developers.facebook.com/apps)
  * [Google](https://code.google.com/apis/console/)
  * [Foursquare](https://foursquare.com/oauth/)
  * [LinkedIn](https://www.linkedin.com/secure/developer)
  * [Tumblr](http://www.tumblr.com/oauth/apps)

    



License
=======

Public Domain Dedication
------------------------

This work is a compilation and derivation from other previously released works. With the exception of various included works, which may be restricted by other licenses, the author or authors of this code dedicate any and all copyright interest in this code to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this code under copyright law.