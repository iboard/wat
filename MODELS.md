
Models
======
    
The 'Facility-Idea'
-------------------

A facility has a name (like 'Admin', 'Author') and an access-mask like the unix-filesystem (rwx)
Facilities are embedded to the user and helper-functions like _can_execute?('Admin')_ will return true or false if the user has this facility.

Next step will be: Models like 'Page' will embed Facilities too in order to support code like this:

```ruby
  @page.facilities.create(name: 'user one', access: 'rw-')
  if current_user.can_write_on?(@page)
    ...
  end
```

A Facility can have an array of 'consumer_ids' which points to
users. Mean's if the given User is listed in this array this user will
be granted with :access rights.


Facility to connect users
-------------------------

A user can embed several facilities with a list of 'consumers'/'friends'.
E.g. a user can add a Facility named 'My Friends' with a list of other
users. Then, the user can add this Facility to e.g. a Page to grant her friend
'rwx'-access to this page.


Model Page
----------

* A page has a _parmalink_ which is used as a key -> http://..../permalink
* Title and body can be translated using mongoID `:localize => true`
* Use permalink 'hero' for the "Hero-Page" displayed at the root-path
* Begin permalink with @ will make a page "featured" and displays the page below the hero-page at the root_path.
* Create a page in any language. Save it. Switch language (at the bottom of the screen). Edit the page and translate it.
* Create one page permalinked as 'README' or remove the menu-item from `views/layout/application.haml`
