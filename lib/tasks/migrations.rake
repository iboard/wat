namespace :migrations do

  desc "Modify data between versions > August 8, 2012 "
  task :localize_banner_fields => :environment do
    Page.all.each do |page|
      page.versionless do |_page|
        _old_title = _page.banner_title_translations
        _old_text  = _page.banner_text_translations
        _new_title = _old_title
        _new_text  = _new_title
        unless _old_title.class == BSON::OrderedHash
          _new_title = { "en" => _old_title }
          puts "CONVERTING #{_old_title.inspect} TO #{_new_title.inspect}"
        end
        unless _old_text.class == BSON::OrderedHash
          _new_text = { "en" => _old_text }
          puts "CONVERTING #{_old_text.inspect} TO #{_new_text.inspect}"
        end
        _page.banner_title_translations = _new_title
        _page.banner_text_translations  = _new_text
        _page.save
      end
    end
  end

  desc "Subscribe existing users to timeline 'doorkeeper', new users will now be subscribed when created, August 20, 2012"
  task :subscribe_all_users_to_doorkeeper => :environment do
    _tl = Timeline.find_or_create_by name: 'doorkeeper'
    User.all.each do |user|
      puts "Subscribe #{user.name} to Timeline '#{_tl.name}'"
      user.subscribe_timelines( _tl )
      puts "User now subsribed to #{user.timelines.map(&:name).join(', ')}"
    end
  end

  desc "Set default timeline-flags public, enabled to true > August 26, 2012"
  task :timeline_flags_public_enabled => :environment do
    Timeline.all.each { |_tl| _tl.update_attributes public: true, enabled: true }
  end
  
end