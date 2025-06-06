class Api::V1::ShortUrlsController < ApplicationController
  def create
    urls = params[:urls]

    unless urls.is_a?(Array) && urls.all? { |u| u.is_a?(String) }
      return render json: { error: 'Invalid payload. Expecting: { urls: ["https://example.com", ...] }' }, status: :bad_request
    end

    results = urls.map do |url|
      existing = ShortUrl.find_by(original_url: url, active: true)
      if existing
        {
          original_url: url,
          short_code: existing.short_code,
          shortened_url: short_url(existing.short_code),
          status: 'exists'
        }
      else
        short_url = ShortUrl.create!(original_url: url)
		short_url.generate_and_assign_short_code!
        {
          original_url: url,
          short_code: short_url.short_code,
          shortened_url: short_url(short_url.short_code),
          status: 'created'
        }
      end
    end

    render json: { data: results }, status: :created
  end

  def deactivate
	short_url = ShortUrl.find_by(id: params[:id])

	unless short_url
		return render json: { error: 'Short URL not found' }, status: :not_found
	end

	if short_url.active?
		short_url.update(active: false)
		render json: { message: 'Short URL deactivated successfully' }, status: :ok
	else
		render json: { message: 'Short URL is already deactivated' }, status: :ok
	end
  end

  private

  def short_url(code)
    "#{request.base_url}/#{code}"
  end
end
