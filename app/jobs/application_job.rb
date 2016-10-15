class ApplicationJob < ActiveJob::Base

  queue_as :default

  class << self
    attr_accessor :perform_needs_new_connection

    def inherited(subclass)
      subclass.prepend PerformDecorator
    end

    module PerformDecorator
      def perform(*)
        if ApplicationJob.perform_needs_new_connection
          ActiveRecord::Base.connection_pool.with_connection do
            super
          end
        else
          super
        end
      end
    end
  end

end
