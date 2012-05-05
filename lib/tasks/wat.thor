# -*- encoding : utf-8 -*-
class Wat < Thor
  desc "undefined_locales [en.yml] [en]", "Find undefined locales"
  def undefined_locales(locale_file,locale)

    used_strings = []
    ignored_dirs = %w(log tmp doc vendor)


    Dir['**/*'].each do |file|
      next if ignored_dirs.include?( file.split(/\//).first)
      if File::ftype(file) == "file"
        begin
          File::read(file).each_line do |line|
            line.gsub( /\s+t\(\s?\:(\w+)\s?\)/ ) do |x|
              used_strings << x.gsub(/t\(\:/,'').gsub(/\)$/,'')
            end
          end
        rescue => e
          # ignore
        end
      end
    end

    locale_en = YAML::load( File::read( "config/locales/#{locale_file}") )[locale]
    defined_keys = []
    not_defined_keys = []
    used_strings.each do |key|
      if locale_en[key.strip] != nil
        defined_keys << key
      else
        not_defined_keys << key
      end
    end

    if not_defined_keys.any?
      puts "NOT DEFINED KEYS:"
      not_defined_keys.uniq.sort.each do |key|
        puts "  #{key}: #{key.to_s}"
      end
    else
      puts "ALL KEYS DEFINED"
    end
  end
end
