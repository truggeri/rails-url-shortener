#
# Controller for Short actions including lookup
#
class ShortsController < ApplicationController
  before_action :load_short, only: %i[lookup]

  def lookup
    redirect_to(@short.full_url)
  end

  private

  def load_short
    @short = Short.find_by(short_url: params[:id])
    return nil if @short.present?

    render_status(404)
  end
end
