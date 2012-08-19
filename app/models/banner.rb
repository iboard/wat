# -*- encoding : utf-8 -*-

# A banner is attached to a page and will be displayed on top of the page.
# The banner can have an URL which will be opened when the banner is clicked.


class Banner
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  embedded_in :page, inverse_of: :banner


  field   :linked_url, default: '#'

  has_mongoid_attached_file :banner,
                            styles: {
                              large:  "900x300#",
                              preview: "300x100#"
                            }
end