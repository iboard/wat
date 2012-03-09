class Page

  include Mongoid::Document
  include Mongoid::Timestamps

  key  :title
  validates_presence_of :title
  validates_uniqueness_of :title

  field :body, type: String

  def is_hero?
    title == 'hero'
  end

  def is_featured?
    title[0] == '@'
  end

end