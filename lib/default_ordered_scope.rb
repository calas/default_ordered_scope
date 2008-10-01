# DefaultOrderedScope

require 'qvitta/default_ordered_scope'

if defined?(ActiveRecord)
  ActiveRecord::Base.class_eval do
    include Qvitta::DefaultOrderedScope
  end
end
