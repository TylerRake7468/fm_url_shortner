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
          shortened_url: get_short_url(existing.short_code),
          status: 'exists'
        }
      else
        short_url = ShortUrl.create!(original_url: url)
		short_url.generate_and_assign_short_code!
        {
          original_url: url,
          short_code: short_url.short_code,
          shortened_url: get_short_url(short_url.short_code),
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

  def analytics
	  timezone = parse_timezone(params[:timezone]) || Time.zone
	  start_date = parse_date(params[:start_date])
	  end_date = parse_date(params[:end_date])

	  short_urls = ShortUrl.where(active: true).includes(:clicks).map do |url|
	    {
	      id: url.id,
	      original_url: url.original_url,
	      short_code: url.short_code,
	      total_clicks: url.clicks.count,
	      filtered_clicks: filtered_clicks(url, start_date, end_date, timezone)
	    }
	  end

	  render json: short_urls
  end

  private

  def get_short_url(code)
    "#{request.base_url}/#{code}"
  end

  def filtered_clicks(url, start_date, end_date, timezone)
	scope = url.clicks
	scope = scope.where('created_at >= ?', start_date.in_time_zone(timezone)) if start_date
	scope = scope.where('created_at <= ?', end_date.in_time_zone(timezone).end_of_day) if end_date
	scope.count
  end

  def parse_date(date_str)
	Date.parse(date_str) rescue nil
  end

  def parse_timezone(tz_str)
	return nil unless tz_str.present?

	ActiveSupport::TimeZone[tz_str] || ActiveSupport::TimeZone.all.find { |tz| tz.formatted_offset == tz_str }
  end
end
