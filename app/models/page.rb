# -*- encoding : utf-8 -*-
class Page

  include Mongoid::Document
  include Mongoid::Timestamps

  key  :permalink
  validates_presence_of :permalink
  validates_uniqueness_of :permalink

  field :title, type: String, :localize => true
  validates_presence_of :title
  
  field :body, type: String, :localize => true

  def is_hero?
    permalink == 'hero'
  end

  def is_featured?
    permalink[0] == '@'
  end

end