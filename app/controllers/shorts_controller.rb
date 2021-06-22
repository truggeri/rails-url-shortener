#
# Controller for Short actions including lookup
#
class ShortsController < ApplicationController
  before_action :authorize_user,  only: %i[create destroy]
  before_action :load_short,      only: %i[destroy show]
  before_action :validate_params, only: %i[create]

  def show
    redirect_to(@short.full_url)
  end

  def create
    details = { full_url: params[:full_url] }
    if params[:short_url].present?
      details[:short_url]      = params[:short_url].downcase
      details[:user_generated] = true
    end

    @short = Short.create(details)
    return render(json: @short.marshall, status: 200) if @short.valid?

    render_status(400)
  end

  def destroy
    status = @short.destroy ? 200 : 400
    render(json: {}, status: status)
  end

  private

  def authorize_user
    # TODO: implement user based control
    return nil if true # rubocop:disable Lint/LiteralAsCondition

    render_status(401)
  end

  def load_short
    @short = Short.find_by(short_url: params[:id])
    return nil if @short.present?

    render_status(404)
  end

  def validate_params
    return nil if short_params.key?(:full_url)

    render_status(400)
  end

  def short_params
    params.permit(:full_url, :short_url)
  end
end
