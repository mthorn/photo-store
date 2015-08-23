class TagJob < ActiveJob::Base

  queue_as :default

  def perform(library, method)
    ActiveRecord::Base.connection_pool.with_connection do
      library.uploads.find_each(&method.to_sym)
    end
  end

end

