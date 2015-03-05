module Psych::Visitors
  ToRuby.class_eval do
    alias :resolve_class_without_autoload :resolve_class
    def resolve_class klassname
      begin
        require_dependency klassname.underscore
      rescue NameError, LoadError
      end

      resolve_class_without_autoload klassname
    end
  end
end
