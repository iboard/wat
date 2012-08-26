# -*- encoding : utf-8 -*-"
#
# Created by Andi Altendorfer <andreas@altendorfer.at>, 21.08.12, 12:39
#
#


class ProfilePresenter < BasePresenter

  presents :profile
  attr_reader :user_presenter

  def initialize(object, template)
    super
    @user_presenter = UserPresenter.new(profile.user, template)
  end

  def profile_page_title
    I18n.t(:users_profile, name: profile.user.name)
  end

  def firstname
    profile.firstname
  end

  def lastname
    profile.lastname
  end

  def dob
    I18n.l(profile.dob) if profile.dob
  end

  def phone_number
    "<i class='icon-play-circle'></i>&nbsp;#{profile.phone_number}".html_safe unless profile.phone_number.blank?
  end

  def mobile
    "<i class='icon-play-circle'></i>&nbsp;#{profile.mobile || '' }".html_safe unless profile.mobile.blank?
  end

end