module AdminTimeline

  def self.user_changed( _user, _what )
    _tl = find_or_create_admin_timeline()
    _tl.create_event( {message: '', what: _what, user_name: _user.name}, UserChangedEvent)
  end

  def self.profile_changed( _user, _what )
    _tl = find_or_create_admin_timeline()
    _tl.create_event( {message: '', what: _what, sender_id: _user._id}, ProfileChangedEvent)
  end

  protected
  def self.find_or_create_admin_timeline
    _tl = Timeline.find_by(name: 'Admin' )
    if !_tl
      _tl = Timeline.create(name: 'Admin' )
      _tl.facilities.create name: 'Admin', access: 'rwx'
    end
    _tl
  end

end