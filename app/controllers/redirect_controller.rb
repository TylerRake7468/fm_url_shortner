class RedirectController < ApplicationController
  def show
    short_url = ShortUrl.find_by(short_code: params[:short_code])

    if short_url.nil? || !short_url.active?
      render plain: "URL not found or inactive", status: :not_found
      return
    end

    short_url.clicks.create(
      clicked_at: Time.current,
      ip_address: request.remote_ip
    )

    redirect_to short_url.original_url, allow_other_host: true
  end
end