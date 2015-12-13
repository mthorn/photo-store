class JserrorsController < ApplicationController

  def log
    if params[:error].present?
      logger.debug '===== JS ERROR START ====='
      params[:error].split(/\r?\n/).each do |line|
        logger.debug(line)
      end
      logger.debug '===== JS ERROR END   ====='
    end
    head :ok
  end

end
