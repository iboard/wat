# -*- encoding : utf-8 -*-
class Facility
  include Mongoid::Document

  unless defined?(WAT_APPLICATION_FACILITIES)
    WAT_APPLICATION_FACILITIES = [[I18n.translate(:admin), 'Admin'], [I18n.translate(:author), 'Author']]
  end
  
  field :name
  validates_presence_of :name
  field :access, type: String, default: "r--"
  
  embedded_in :user  
  field :owner_id,     type: BSON::ObjectId
  field :consumer_ids, type: Array

  def owner
    self.owner_id ? User.find(self.owner_id) : self.user
  end

  def consumers
    User.any_in( _id: self.consumer_ids )
  end
  def consumers=(user_array)
    self.consumer_ids=user_array.map(&:_id)
  end
  def add_consumers(new_users)
    self.consumer_ids ||= []
    self.consumer_ids += new_users.map(&:_id)
  end

  
  def can_read?
    self.access[0].downcase == 'r'
  end
  
  def can_write?
    self.access[1].downcase == 'w'
  end
  
  def can_execute?
    self.access[2].downcase == 'x'
  end

  def can_read
    access[0] == "r"
  end
  
  def can_write
    access[1] == "w"
  end

  def can_execute
    access[2] == "x"
  end

  def can_read=(allow)
    access[0] = allow=="1" ? 'r' : '-'
  end

  def can_write=(allow)
    access[1] = allow=="1" ? 'w' : '-'
  end

  def can_execute=(allow)
    access[2] = allow=="1" ? 'x' : '-'
  end

  def delete_or_remove_consumer(_contact)
    self.consumer_ids -= [_contact._id]
    self.delete if self.consumer_ids.empty?
  end

  def self.available_facilities
    @facility_select ||= if Facility::respond_to?(:extra_facilities)
      WAT_APPLICATION_FACILITIES + Facility::extra_facilities
    else
      WAT_APPLICATION_FACILITIES
    end
  end
  
end
