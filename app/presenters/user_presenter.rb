class UserPresenter < BasePresenter
  presents :user

  def options_menu
    content_tag :ul, class: "nav pull-right" do
      option_dropdown
    end
  end

  def name
    if !user.respond_to?(:name)
      content_tag( :span, class: 'none_given') { I18n.t(:no_name_given) }
    else
      user.name
    end
  end

  def name_and_profile_link
    _rc = ""
    if !user.respond_to?(:name)
      _rc += content_tag( :span, class: 'none_given') { I18n.t(:no_name_given) }
    else
      _rc += user.name
    end
    if user.profile && (user.profile.is_public || user == current_user)
      _rc += "<ul class='nav pull-right'><li>" +
          button_link_to( 'icon-share icon-white', 'btn btn-primary', t(:user_profile),  user_profile_path(user) ) +
          "</li></ul>"
    end
    _rc.html_safe
  end

  def social_media_links
    links = []
    if user.profile
      unless (user.profile.twitter_handle||'').blank?
        links << link_to( '<i class="icon-share icon-white"></i> Twitter'.html_safe, "http://twitter.com/#{user.profile.twitter_handle}", target: :blank, class: 'btn btn-mini btn-warning')
      end
      unless (user.profile.facebook_profile||'').blank?
        links << link_to( '<i class="icon-share icon-white"></i> Facebook'.html_safe, "http://facebook.com/#{user.profile.facebook_profile}", target: :blank, class: 'btn btn-mini btn-warning')
      end
      unless (user.profile.google_uid||'').blank?
        links << link_to( '<i class="icon-share icon-white"></i> Google+'.html_safe, "https://plus.google.com/#{user.profile.google_uid}/about", target: :blank, class: 'btn btn-mini btn-warning')
      end
    end
    links.join(" ").html_safe
  end

  def email
    icon_link_to 'icon-envelope', '', user.email
  end

  def confirmed_at
    t(:email_confirmed_at, when:  user.email_confirmed_at ? localize(user.email_confirmed_at) : t(:not_confirmed_yet))
  end

  def exists_since
    t(:account_exists_since, when: localize(user.created_at||(Time.now-48.years)))
  end

  def facilities
    rc = ""
    user.facilities_string do |str|
      rc += content_tag :p do
        str
      end
    end
    rc.html_safe
  end

  def oauth_providers
    if user.authentications.any?
      content_tag :p do
        content_tag( :strong, t(:connected_providers))+
        provider_list
      end
    end
  end
    
  def avatar(size=:avatar)
    image_tag( user.picture(size), class: 'avatar', style: Avatar::css_size_for(size))
  end

  def location
    unless user.location_token.blank?
      if user == current_user
        t(:your_location, location: user.location_token )
      else
        t(:location, location: user.location_token )
      end
    end
  end

private
  def user_gravatar(size=:avatar)
    _url, options = user.gravatar_path(size)
    image_tag _url, class: 'avatar', style: options
  end

  def user_avatar(size=:avatar)
    if user.avatar && user.avatar.avatar.original_filename
      image_tag user.avatar.avatar.url(size), class: 'avatar'
    else
      no_avatar(size)
    end
  end

  def no_avatar(size=:avatar)
    content_tag :img, class: "avatar avatar_#{size}" do
    end
  end

  def provider_list
    content_tag(:ul) {
      user.authentications.map { |auth|
        content_tag :li, auth.provider.to_s.humanize
        }.join("\n").html_safe
    }
  end

  def option_dropdown
    content_tag :li, class: Rails.env != 'test' ? "dropdown" : "" do
      option_icon + option_items    
    end
  end

  def option_icon
    icon_link_to( 'icon-cog ' + (current_user == user ? 'icon-white' : ''), current_user == user ? 'btn btn-primary' : 'btn', '<b class="caret"></b>'.html_safe, "#", :class => 'dropdown-toggle', 'data-toggle' => 'dropdown')
  end

  def option_items
    content_tag :ul, :class => Rails.env != 'test' ? "dropdown-menu" : "" do
      if user == current_user
        edit_item + standard_items
      elsif can_execute?('Admin')
        content_tag :li, id: "#{user.id.to_s}-edit-button" do
          icon_link_to( 'icon-cog', '', t(:edit_facilities), user_facilities_path(user), id:"#{user.id.to_s}-edit-button")
        end
      end
    end
  end

  def edit_item
    if params[:action] == "show"
      content_tag :li, id: "#{user.id.to_s}-edit-button" do
        icon_link_to( 'icon-edit', '', t(:edit), edit_user_path(user))
      end
    else
      content_tag :li, id: "#{user.id.to_s}-edit-button" do
        icon_link_to( 'icon-edit', '', t(:your_profile), user)
      end
    end
  end

  def standard_items
    content_tag :li do
      icon_link_to( 'icon-remove', '', t(:cancel_account), user, method: :delete, confirm: t(:are_you_sure))
    end
  end

  def gravatar_id
    user.gravatar_id
  end


end