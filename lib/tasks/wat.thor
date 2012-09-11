# -*- encoding : utf-8 -*-
class Wat < Thor

  desc "undefined_locales [en.yml] [en]", "Find undefined locales"
  def undefined_locales(locale_file, locale)

    ignored_dirs = %w(log tmp doc vendor)
    used_strings = read_used_strings(ignored_dirs)
    locale_hash = load_locale(locale_file, locale)
    if (_n=not_defined_keys(locale_hash, used_strings)).any?
      print_undefined_keys(_n)
    else
      puts "ALL KEYS DEFINED"
    end
  end

  private

  def load_locale(locale_file,locale)
    YAML::load(File::read("config/locales/#{locale_file}"))[locale]
  end

  def read_used_strings(ignored_dirs)
    used_strings = []
    Dir['**/*'].each do |file|
      next if ignored_dirs.include?(file.split(/\//).first)
      read_used_files(file, used_strings) if File::ftype(file) == "file"
    end
    used_strings
  end

  def print_undefined_keys(keys)
    puts "NOT DEFINED KEYS:"
    keys.uniq.sort.each do |key|
      puts "#{key.strip}: \"#{key.to_s.strip}\""
    end
  end

  def read_used_files(file, used_strings)
    begin
      File::read(file).each_line do |line|
        line.gsub(/\s+t\(\s?\:(\w+)\s?\)/) do |x|
          used_strings << x.gsub(/t\(\:/, '').gsub(/\)$/, '')
        end
      end
    rescue
      #ignore
    end
  end

  def not_defined_keys(locale_en, used_strings)
    used_strings.select { |key| locale_en[key.strip].nil? }
  end

end
