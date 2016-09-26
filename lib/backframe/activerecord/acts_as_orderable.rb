# encoding: utf-8

module Backframe
  module ActsAsOrderable
    extend ActiveSupport::Concern

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def acts_as_orderable(field, on)
        class_eval <<-EOV, __FILE__, __LINE__ + 1
          validates_presence_of :#{field}
          validates_presence_of :#{on}

          before_validation :set_#{field}, :on => :create
          after_destroy :reorder_#{field}

          default_scope -> { order(:#{field} => :asc) }

          def set_#{field}
            self.#{field} ||= (self.#{on}.#{self.name.tableize}.any?) ? self.#{on}.#{self.name.tableize}.maximum(:#{field}) + 1 : 0
          end

          def reorder_#{field}
            self.#{on}.#{self.name.tableize}.order(:#{field} => :asc).each_with_index do |item, index|
              item.update_column(:#{field}, index)
            end
          end
        EOV
      end
    end
  end
end
