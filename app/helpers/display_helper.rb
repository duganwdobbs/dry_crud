module DisplayHelper
  DISPLAY_NAME_FALLBACK = -> {
    name = ""
    klass = self.class
    name << klass.model_name.human if klass.respond_to? :model_name
    name << " ##{send(klass.primary_key)}" if klass.respond_to? :primary_key
    name.present? ? name : to_s
  }
  def DISPLAY_NAME_FALLBACK.inspect
    "DISPLAY_NAME_FALLBACK"
  end

  # DryCrud makes educated guesses when displaying objects, this is
  # the list of methods it tries calling in order
  DISPLAY_NAME_METHODS ||= [ :dry_crud_display_name,
                             :display_name,
                             :full_name,
                             :name,
                             :username,
                             :login,
                             :title,
                             :email,
                             :to_s ].freeze


  # Attempts to call any known display name methods on the resource.
  # See the setting in `application.rb` for the list of methods and their priority.
  def display_name(resource)
    ERB::Util.html_escape(resource.send display_name_method_for(resource)) unless resource.nil?
  end

  # Looks up and caches the first available display name method.
  # To prevent conflicts, we exclude any methods that happen to be associations.
  # If no methods are available and we're about to use the Kernel's `to_s`, provide our own.
  def display_name_method_for(resource)
    @@display_name_methods_cache ||= {}
    @@display_name_methods_cache[resource.class] ||= begin
      methods = DISPLAY_NAME_METHODS - association_methods_for(resource)
      method = methods.detect { |method| resource.respond_to? method }

      if method != :to_s || resource.method(method).source_location
        method
      else
        DISPLAY_NAME_FALLBACK
      end
    end
  end

  def association_methods_for(resource)
    return [] unless resource.class.respond_to? :reflect_on_all_associations
    resource.class.reflect_on_all_associations.map(&:name)
  end
end
