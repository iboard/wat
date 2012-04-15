class UserPresenter < BasePresenter
  presents :user

  def options_menu
    content_tag :ul, class: "nav pull-right" do
      option_dropdown
    end
  end
  
  def name
    unless user.respond_to?(:name)
      content_tag( :span, class: 'none_given') {
          I18n.t(:no_name_given) 
        }
    else
      user.name
    end
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
    
  def avatar
    if user.profile && user.profile.use_gravatar
      _url = "http://gravatar.com/avatar/#{gravatar_id}.png?cache=#{(user.updated_at||Time.now).strftime('%Y%m%d%H%M%S')}"
      image_tag _url, class: 'avatar'
    end
  end

private
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
    Digest::MD5.hexdigest(user.email.downcase) if user.email
  end


end