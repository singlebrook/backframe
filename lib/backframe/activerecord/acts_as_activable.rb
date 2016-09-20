# encoding: utf-8

module Backframe
  module ActsAsActivable
    extend ActiveSupport::Concern

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def acts_as_activable(entity, text, link)
        class_eval <<-EOV, __FILE__, __LINE__ + 1
          def activities
            conditions = []
            conditions << '("activities"."object1_type"=? AND "activities"."object1_id"=?)'
            conditions << '("activities"."object2_type"=? AND "activities"."object2_id"=?)'
            if self.is_a?(Admin) || self.is_a?(Customer)
              conditions << '"activities"."subject_type"=? AND "activities"."subject_id"=?'
            end
            fragment = [conditions.join(' OR '), self.class.name, self.id, self.class.name, self.id]
            fragment.concat([self.class.name, self.id]) if self.is_a?(Admin) || self.is_a?(Customer)
            Activity.where(fragment)
          end

          def activity_entity
            "#{entity}"
          end

          def activity_text
            self.#{text}
          end

          def activity_link
            link = "#{link}"
            "#{link}".scan(/\\\[([\\\w\\\_]*)\\\]/).each do |token|
              link = link.gsub('['+token.first+']', self.send(token.first).to_s)
            end
            link
          end
        EOV
      end
    end
  end
end
