
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
