class Facility
  FACILITY_SELECT=[[I18n.translate(:admin), 'Admin'], [I18n.translate(:author), 'Author']]
  include Mongoid::Document

  field :name
  field :access, type: String, default: "r--"

  validates_presence_of :name
  
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
  
end
