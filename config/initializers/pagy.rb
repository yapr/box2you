# Pagy initializer file

# Instance variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#variables
Pagy::DEFAULT[:items] = 20        # items per page
Pagy::DEFAULT[:size] = 7          # nav bar links (number of page links to show)

# Enable overflow extra for handling large page numbers
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

# Enable metadata extra for JSON API responses
require "pagy/extras/metadata"

# Enable i18n extra for internationalization
require "pagy/extras/i18n"

# Set default locale
Pagy::I18n.load(locale: "en")
