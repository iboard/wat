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

  belongs_to :section
  embeds_one :banner, :cascade_callbacks => true
  accepts_nested_attributes_for :banner
  field  :banner_title
  field  :banner_text
  field  :banner_text_position, default: 'right'

  before_validation :remove_banner?

  def self.with_banner 
    self.excludes( banner: nil).excludes( :'banner.banner_file_size' => nil ).desc(:updated_at)
  end

  def is_hero?
    permalink == 'hero'
  end

  def is_featured?
    permalink[0] == '@'
  end

  def preview_length_or_default
    self.preview_length || Settings.default_preview_length || 300
  end

  def banner_exist?
    self.banner && (self.banner.banner_file_size||0) > 0
  end

  def delete_banner=(value)
    @delete_banner = value == "1"
  end

  def delete_banner
    @delete_banner ||= false
  end

private
  def remove_banner?
    if @delete_banner
      self.banner.delete if self.banner
      self.banner = nil
    end
  end


end