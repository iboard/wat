# -*- encoding : utf-8 -*-
namespace :wat do
  desc "Find undefined locales"
  task :undefined_locales => :environment do

    used_strings = []

    Dir['**/*'].each do |file| 
      if File::ftype(file) == "file"
        begin
          File::read(file).each_line do |line|
            line.gsub( /t\(\:(\S+)\)/ ) do |x|
              used_strings << x.gsub(/t\(\:/,'').gsub(/\)$/,'')
            end
          end
        rescue => e
          # ignore
        end
      end
    end

    locale_en = YAML::load( File::read( 'config/locales/en.yml') )['en']
    defined_keys = []
    not_defined_keys = []
    used_strings.each do |key|
      if locale_en[key].present?
        defined_keys << key
      else
        not_defined_keys << key
      end
    end

    if not_defined_keys.any?
      puts "NOT DEFINED KEYS:"
      not_defined_keys.uniq.sort.each do |key|
        puts "  #{key}: #{key.to_s.humanize}"
      end
    else
      puts "ALL KEYS DEFINED"
    end
  end
end
