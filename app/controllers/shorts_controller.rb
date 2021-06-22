#
# Controller for Short actions including lookup
#
class ShortsController < ApplicationController
  before_action :load_short, only: %i[lookup]

  def lookup
    redirect_to(health_path)
  end

  private

  def load_short
    # TODO: load real short
    @short = nil
    return nil if @short.present?

    render_status(404)
  end
end
