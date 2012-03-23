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
  field :preview_length, type: Integer
  validates :preview_length, :numericality => { :only_integer => true, :greater_than => 3 }, :allow_nil => true

  def is_hero?
    permalink == 'hero'
  end

  def is_featured?
    permalink[0] == '@'
  end

  def preview_length_or_default
    self.preview_length || Settings.default_preview_length || 300
  end

end