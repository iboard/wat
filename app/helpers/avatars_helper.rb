# -*- encoding : utf-8 -*-

module AvatarsHelper 

  def avatar(size)
    return "".html_safe unless current_user
    rc=""
    present current_user do |p|
      rc = p.avatar(size)
    end
    (rc||"").html_safe
  end
end