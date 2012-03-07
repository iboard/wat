class Facility
  include Mongoid::Document

  field :name
  field :access, type: String, default: "r--"
  
  embedded_in :user
  
  def can_read?
    self.access[0].downcase == 'r'
  end
  
  def can_write?
    self.access[1].downcase == 'w'
  end
  
  def can_execute?
    self.access[2].downcase == 'x'
  end
end
