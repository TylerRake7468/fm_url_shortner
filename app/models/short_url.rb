class ShortUrl < ApplicationRecord
  has_many :clicks, dependent: :destroy

  validates :original_url, presence: true

  CHARACTERS = [*'a'..'z', *'A'..'Z', *'0'..'9'].freeze

  def generate_and_assign_short_code!
    update!(short_code: encode_base62(id))
  end

  def clicks_in_range(start_date, end_date, timezone)
    return clicks.none unless start_date && end_date

    zone = timezone || Time.zone
    start_time = zone.parse(start_date.to_s).beginning_of_day
    end_time = zone.parse(end_date.to_s).end_of_day

    clicks.where(clicked_at: start_time..end_time)
  end

  private

  def encode_base62(num)
    return CHARACTERS[0] if num == 0
    s = ''
    base = CHARACTERS.length
    while num > 0
      s.prepend(CHARACTERS[num % base])
      num /= base
    end
    s
  end
end
