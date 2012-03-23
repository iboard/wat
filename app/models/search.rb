class Search
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  attr_accessor :search_text, :search_controller
  
  def initialize(attributes)
    @search_text = attributes[:search_text] || ""
    @search_controller = attributes[:search_controller] || "pages"
  end
  
  def persisted?
    false
  end
  
  # Don't start search if we have not 3 chars at least.
  def valid?
    self.search_text && self.search_text.length > 0
  end
  
end
