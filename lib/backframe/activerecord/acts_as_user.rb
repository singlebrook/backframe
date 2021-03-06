# encoding: utf-8

module Backframe
  module ActsAsUser
    extend ActiveSupport::Concern

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def acts_as_user(*args)
        arguments = args[0] || {}

        reset = arguments[:reset] || 'Backframe::Reset'
        activation = arguments[:activation] || 'Backframe::Activation'

        attr_accessor :password, :change_password, :set_password, :old_password, :new_password, :confirm_password, :confirm_email

        has_many :activations, :class_name => activation, :dependent => :destroy, :as => :user
        has_many :resets, :class_name => reset, :dependent => :destroy, :as => :user

        after_validation :set_new_password, :if => Proc.new { |u| u.new_password.present? }
        after_create :activate

        validates_presence_of :first_name, :last_name, :email
        validate :validate_password, :if => Proc.new { |u| u.change_password.present? || u.set_password.present? }

        class_eval <<-EOV, __FILE__, __LINE__ + 1
          def full_name
            self.first_name+' '+self.last_name
          end

          def rfc822
            self.full_name+' <'+self.email+'>'
          end

          def locked_out?
            self.signin_locked_at.present? && self.signin_locked_at > Time.now.ago(5.minutes)
          end

          def signin(status)
            if status == :success
              self.signin_locked_at = nil
              self.signin_attempts = 0
            elsif status == :failed
              self.signin_attempts += 1
              if self.signin_attempts >= 5
                self.signin_attempts = 0
                self.signin_locked_at = Time.now
              end
            end
            self.save
          end

          def authenticate(password)
            self.password_hash == BCrypt::Engine.hash_secret(password, self.password_salt)
          end

          def password=(password)
            @password = password
            self.password_salt = BCrypt::Engine.generate_salt
            self.password_hash = BCrypt::Engine.hash_secret(password, self.password_salt)
          end

          def password
            @password
          end

          def validate_password
            if self.change_password && self.old_password.blank?
              return self.errors.add(:old_password, I18n.t('activerecord.errors.messages.blank'))
            elsif self.change_password && !authenticate(self.old_password)
              return self.errors.add(:old_password, I18n.t(:user_invalid_old_password))
            elsif self.new_password.blank? || self.confirm_password.blank?
              return self.errors.add(:new_password, I18n.t(:user_unconfirmed_password))
            elsif self.confirm_password != self.new_password
              return self.errors.add(:new_password, I18n.t(:user_unmatching_passwords))
            end
          end

          def set_new_password
            self.password = self.new_password
          end

          def activate
            self.activations.create
          end

          # Create a `Reset` record and send an email.
          def reset
            self.resets.create
          end
        EOV
      end
    end
  end
end
