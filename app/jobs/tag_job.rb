class TagJob < ApplicationJob

  def perform(library, method)
    library.uploads.find_each(&method.to_sym)
  end

end

