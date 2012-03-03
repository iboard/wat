WAT (WebApplicationTemplate)
============================

WAT is derived from RailsApp/templates by [Daniel Kehoe](https://github.com/DanielKehoe)

It uses

  * MongoDB / MongoID
  * OmniAuth
  * HAML

and is based on Rails 3.2.1

  * See [GitHub/RailsApps](https://github.com/RailsApps/rails3-application-templates)

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

Installation
============

  1. Clone or fork this project from Github
  2. copy config/test_secrets.yml to config/secrets.yml and 
    * Enter your API-Keys
    * Disable services you don't want by remarking it.
  3. bundle
  4. Run `bundle execute guard`


License
=======

Public Domain Dedication
------------------------

This work is a compilation and derivation from other previously released works. With the exception of various included works, which may be restricted by other licenses, the author or authors of this code dedicate any and all copyright interest in this code to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this code under copyright law.