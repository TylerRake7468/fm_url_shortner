# URL Shortener API

This is a Ruby on Rails API application for shortening URLs, managing their lifecycle, and tracking click analytics. It supports batch shortening, unique short code generation, deactivation, redirection, and timezone-aware analytics.

---

## 🔧 Tech Stack

- Ruby on Rails (API-only)
- PostgreSQL

---

## ⚙️ Setup Instructions

1. **Clone the repo**
   => git clone git@github.com:TylerRake7468/fm_url_shortner.git
   => cd url-shortener-api
2. **bundle install**
   => bundle install
3. **Setup the database**
   => rails db:create db:migrate
4. **Run the server**
   => rails server

## API Endpoints

### 1. Shorten URLs
POST  /api/v1/short_urls

Single URL body:
<pre>
{
	"urls": ["https://instagram.com"]
}</pre>

Response:
<pre>
{
    "data": [
        {
            "original_url": "https://instagram.com",
            "short_code": "i",
            "shortened_url": "http://127.0.0.1:3000/i",
            "status": "created"
        }
    ]
}</pre>

Batch URL's body:
<pre>
{
	"urls": ["https://example1.com", "https://example2.com"]
}</pre>

Response:
<pre>
{
    "data": [
        {
            "original_url": "https://example1.com",
            "short_code": "j",
            "shortened_url": "http://127.0.0.1:3000/j",
            "status": "created"
        },
        {
            "original_url": "https://example2.com",
            "short_code": "k",
            "shortened_url": "http://127.0.0.1:3000/k",
            "status": "created"
        }
    ]
}</pre>

### 2. Deactivate Short URL
PATCH /api/v1/short_urls/:id/deactivate

Response:
<pre>
{
    "message": "Short URL deactivated successfully"
}</pre>

OR
<pre>
{
    "message": "Short URL is already deactivated"
}</pre>


### 3. Redirect + Track Clicks
GET   /:short_code

When you click on short url, this api will
Redirects to the original URL and tracks the click.


### 4. Analytics
GET   /api/v1/short_urls/analytics
<pre>
[
    {
        "id": 4,
        "original_url": "https://guides.rubyonrails.org",
        "short_code": "gc",
        "total_clicks": 3,
        "filtered_clicks": 3
    },
    {
        "id": 5,
        "original_url": "https://rubyonrails.org",
        "short_code": "f",
        "total_clicks": 1,
        "filtered_clicks": 1
    },
    {
        "id": 6,
        "original_url": "https://google.com",
        "short_code": "g",
        "total_clicks": 1,
        "filtered_clicks": 1
    },
    {
        "id": 7,
        "original_url": "https://facebook.com",
        "short_code": "qp",
        "total_clicks": 0,
        "filtered_clicks": 0
    }
]</pre>

This API also accept multiple filters
- start_date - beginning of date range
- end_date - end of date range
- timezone - timezone for the date range filtering, accepting both IANA identifiers (e.g “Europe/Paris”) and ISO 8601 offset (“+5:30”, “-08:00”, “Z”)

Examples: 
- GET /api/v1/short_urls/analytics
- GET /api/v1/short_urls/analytics?start_date=2024-06-01
- GET /api/v1/short_urls/analytics?end_date=2024-06-10
- GET /api/v1/short_urls/analytics?start_date=2024-06-01&end_date=2024-06-05&timezone=Asia/Kolkata
- GET /api/v1/short_urls/analytics?start_date=2024-06-01&end_date=2024-06-05&timezone=America/New_York
- GET /api/v1/short_urls/analytics?start_date=2024-06-01&end_date=2024-06-05&timezone=+05:30
- GET /api/v1/short_urls/analytics?start_date=2024-06-01&end_date=2024-06-05&timezone=-08:00
- GET /api/v1/short_urls/analytics?start_date=2024-06-01&end_date=2024-06-05&timezone=Z
- GET /api/v1/short_urls/analytics?start_date=2024-06-01&end_date=2024-06-05&timezone=Invalid/Zone

Based on these filters the inside response "filtered_clicks" will get change.  


# Shorten URL Algorithm

Base62 encoding technique to generate short codes from integers (like database IDs).

**This algorithm:**

1. Converts a numeric ID (like 12345) into a short Base62 string (like "dnh").
2. Base62 uses [0–9], [a–z], and [A–Z] — 62 characters total.
3. It's compact and URL-friendly.

**Code:** 
```ruby

  def encode_base62(num)
	CHARACTERS = [*'a'..'z', *'A'..'Z', *'0'..'9'].freeze
	# Index 0 → 'a', 25 → 'z', 26 → 'A', 51 → 'Z', 52 → '0', 61 → '9'

    return CHARACTERS[0] if num == 0
    s = ''
    base = CHARACTERS.length
    while num > 0
      s.prepend(CHARACTERS[num % base])
      num /= base
    end
    s
  end
```

**Encoding Example:** Convert 123456789 to Base62

Base = 62
Number to encode = 123456789

- Step 1:

123456789 % 62 = 21
→ CHARACTERS[21] = 'v'

123456789 / 62 = 1991246

- Step 2:

1991246 % 62 = 54
→ CHARACTERS[54] = '2'

1991246 / 62 = 32113

- Step 3:

32113 % 62 = 7
→ CHARACTERS[7] = 'h'

32113 / 62 = 518

- Step 4:

518 % 62 = 22
→ CHARACTERS[22] = 'w'

518 / 62 = 8

- Step 5:

8 % 62 = 8
→ CHARACTERS[8] = 'i'

8 / 62 = 0 (Done)

Final Step
Collected in order: v, 2, h, w, i

short_code: v2hwi


