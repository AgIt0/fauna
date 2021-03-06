module Door::Loggable
  extend ActiveSupport::Concern

  included do
    has_one :log_entry, as: :loggable
    before_create :associate_log_entry
    after_create :spam_irc
  end

  def public_message
  end

  private

  def associate_log_entry
    self.log_entry = build_log_entry
  end

  def spam_irc
    return true if ENV['RAILS_ENV'] == 'test'
    message = public_message
    if message.present?
      begin
        IrcNotifierJob.perform_later message
      rescue Exception
      end
    end
    true
  end
end
