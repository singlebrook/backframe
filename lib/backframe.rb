# encoding: utf-8

require 'backframe/actioncontroller/acts_as_activation'
require 'backframe/actioncontroller/acts_as_api'
require 'backframe/actioncontroller/acts_as_reset'
require 'backframe/actioncontroller/acts_as_resource'
require 'backframe/actioncontroller/acts_as_session'
require 'backframe/activerecord/acts_as_activable'
require 'backframe/activerecord/acts_as_distinct'
require 'backframe/activerecord/acts_as_orderable'
require 'backframe/activerecord/acts_as_status'
require 'backframe/activerecord/acts_as_user'
require 'backframe/activerecord/filter_sort'
require 'backframe/activerecord/migration'
require 'backframe/models/activity'
require 'backframe/models/activation'
require 'backframe/models/reset'
require 'backframe/serializers/activity_serializer'
require 'backframe/mime'


module Backframe

  extend ActiveSupport::Autoload

  autoload :Activity
  autoload :Activation
  autoload :Reset

  module Exceptions
    class Unauthenticated < StandardError; end
    class Unauthorized < StandardError; end
  end

end

require 'backframe/railtie'
