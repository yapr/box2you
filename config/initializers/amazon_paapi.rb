# Amazon Product Advertising API Configuration
# FIXME: Set your actual Amazon PA-API credentials in Rails.application.credentials
#
# Run the following command to set up your credentials:
# rails credentials:edit
#
# Add the following to your credentials file:
# amazon:
#   access_key: YOUR_ACCESS_KEY
#   secret_key: YOUR_SECRET_KEY
#   associate_tag: YOUR_ASSOCIATE_TAG
#   marketplace: JP  # or US, UK, etc.

class AmazonPaapiConfig
  def self.configured?
    Rails.application.credentials.amazon.present? &&
      Rails.application.credentials.amazon[:access_key].present? &&
      Rails.application.credentials.amazon[:secret_key].present? &&
      Rails.application.credentials.amazon[:associate_tag].present?
  end

  def self.access_key
    Rails.application.credentials.amazon[:access_key]
  end

  def self.secret_key
    Rails.application.credentials.amazon[:secret_key]
  end

  def self.associate_tag
    Rails.application.credentials.amazon[:associate_tag]
  end

  def self.marketplace
    Rails.application.credentials.amazon[:marketplace] || "JP"
  end
end

# Rakuten Web Service Configuration
# FIXME: Set your actual Rakuten API credentials in Rails.application.credentials
#
# Add the following to your credentials file:
# rakuten:
#   application_id: YOUR_APPLICATION_ID
#   affiliate_id: YOUR_AFFILIATE_ID

class RakutenConfig
  def self.configured?
    Rails.application.credentials.rakuten.present? &&
      Rails.application.credentials.rakuten[:application_id].present?
  end

  def self.application_id
    Rails.application.credentials.rakuten[:application_id]
  end

  def self.affiliate_id
    Rails.application.credentials.rakuten[:affiliate_id]
  end
end
