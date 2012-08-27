# -*- encoding : utf-8 -*-
class Page

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Versionizer
  include Commentable

  key  :permalink
  validates_presence_of :permalink
  validates_uniqueness_of :permalink
  field :position, type: Integer, default: 0
  field :sorting_id
  validates_uniqueness_of :sorting_id

  field :title, type: String, localize: true
  validates_presence_of :title

  field :body, type: String, localize: true
  field :preview_length, type: Integer
  validates :preview_length, numericality: { only_integer: true, greater_than: 3 }, allow_nil: true

  belongs_to :section
  embeds_one :banner, cascade_callbacks: true
  accepts_nested_attributes_for :banner
  field  :banner_title, localize: true
  field  :banner_text, localize: true
  field  :banner_text_position, default: 'right'

  field  :publish_at, type: Time
  field  :expire_at, type: Time
  field  :is_online, type: Boolean, default: true
  field  :featured, type: Boolean, default: false

  field  :last_modified_by

  before_validation :remove_banner?
  before_validation :generate_sorting_id
  before_validation :set_dates
  before_save :set_is_online
  after_create :fire_page_created_event
  after_update :fire_page_modified_event


  max_versions 10
  def self.ignore_fields_on_restore
    %w(_id permalink attributes version versions position updated_at created_at)
  end
  def self.parameterize_fields
    %w(banner)
  end


  # SCOPES

  default_scope  -> { asc(:position) }
  scope :online, -> { where(is_online: true) }
  scope :offline,-> { where(is_online: false) }

  scope :published,-> {
    any_of( {:publish_at.lte => Time.now},{publish_at: nil} ).only(:_id,:permalink)
  }

  scope :will_publish,-> {
    where( :publish_at.gt => Time.now ).only(:_id).only(:_id,:permalink)
  }

  scope :expired,-> {
    where( :expire_at.lte => Time.now, :expire_at.ne => nil ).only(:_id,:permalink)
  }

  scope :will_expire,-> {
    where( :expire_at.gt => Time.now, :expire_at.ne => nil ).only(:_id,:permalink)
  }

  scope :with_banner,-> {
    excludes( banner: nil).excludes( :'banner.banner_file_size' => nil ).desc(:updated_at)
  }

  scope :featured, -> {
    where :featured => true
  }

  def self.permitted(is_admin)
    is_admin ? unscoped : where(:is_online => true)
  end

  # FLAGS & STATE

  def is_hero?
    permalink == 'hero'
  end

  def is_featured?
    self.featured
  end

  # VIRTUAL ATTRIBUTE
  # #################

  # publish at
  def use_publish_at
    !self.publish_at.nil?
  end

  def use_publish_at=(_publish)
    @use_publish_at = _publish
  end

  def publish_on
    if self.publish_at
      self.publish_at.strformat("%Y.%M.%D")
    end
  end

  def publish_on=(new_date)
    @new_publish_on = new_date
  end

  # expire at
  def use_expire_at
    !self.expire_at.nil?
  end

  def use_expire_at=(_expire)
    @use_expire_at = _expire
  end

  def expire_on
    if self.expire_at
      self.expire_at.strformat("%Y.%M.%D")
    end
  end

  def expire_on=(new_date)
    @new_expire_on = new_date
  end

  # see [fire_page_modified_event]
  # @param [Object] value - Set this to any value except false or nil to get a PageEvent fired on update
  def saved_from_controller=(value)
    @saved_from_controller = value
  end


  # HELPERS

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

  def date_range
    _range = "online"
    _range = "expired" if self.expire_at && self.expire_at <= Time.now
    _range = "queued" if self.publish_at && self.publish_at > Time.now
    _range
  end

private
  def remove_banner?
    if @delete_banner
      self.banner.delete if self.banner
      self.banner = nil
    end
    true
  end

  def generate_sorting_id
    self.sorting_id ||= SecureRandom::hex(21)
  end

  def set_dates
    set_publish_dates
    set_expire_dates
    true
  end

  def set_publish_dates
    if @use_publish_at == "1"
      self.publish_at = DateTime.parse( @new_publish_on + " 00:00 #{Time.zone}" )
    elsif @use_publish_at == "0"
      self.publish_at = nil
    end
    true
  end

  def set_expire_dates
    if @use_expire_at == "1"
      self.expire_at = DateTime.parse( @new_expire_on + " 00:00 #{Time.zone}" )
    elsif @use_expire_at == "0"
      self.expire_at = nil
    end
    true
  end

  def set_is_online
    self.is_online = (self.expire_at == nil || self.expire_at > Time.now)  &&
                     (self.publish_at == nil || self.publish_at <= Time.now)
    true
  end

  def fire_page_created_event
    Timeline.find_or_create_by(name: Doorkeeper::DOORKEEPER_CONTENT).create_event(
        {message: 'action_created', sender_id: self.last_modified_by, page_id: self._id}, PageEvent
    ) if is_online
  end

  def fire_page_modified_event
    Timeline.find_or_create_by(name: Doorkeeper::DOORKEEPER_CONTENT).create_event(
        {message: 'action_saved', sender_id: self.last_modified_by, page_id: self._id}, PageEvent
    ) if is_online && @saved_from_controller
  end

end