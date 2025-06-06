class ShortUrl < ApplicationRecord
  has_many :clicks, dependent: :destroy

  validates :original_url, presence: true

  CHARACTERS = [*'a'..'z', *'A'..'Z', *'0'..'9'].freeze

  def generate_and_assign_short_code!
    update!(short_code: encode_base62(id))
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
