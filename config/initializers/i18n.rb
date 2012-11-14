module  I18n

  def self.track_locales=(new_value)
    @track_locales = new_value
    @used_locales = []
  end

  def self.track_locales?
    @track_locales ||= false
  end

  def self.translate(*args)
    return super unless track_locales?
    @used_locales += [args[0]]
    super
  end

  def self.used_locales
    @used_locales.sort{|a,b| a.to_s <=> b.to_s}.uniq
  end

end