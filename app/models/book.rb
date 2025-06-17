class Book < ApplicationRecord
  has_many :book_translations, dependent: :destroy

  validates :isbn, presence: true, uniqueness: true

  scope :popular, -> { order(popularity_score: :desc) }
  scope :with_cached_summary, -> { where(ai_summary_cached: true) }

  def translation_for(language = "en")
    book_translations.find_by(language: language)
  end

  def title(language = "en")
    translation_for(language)&.title
  end

  def author(language = "en")
    translation_for(language)&.author
  end

  def summary(language = "en")
    translation_for(language)&.summary
  end

  def generate_ai_summary!(language = "en")
    translation = translation_for(language)
    return nil unless translation&.title.present?

    # Skip AI generation if API key is not configured
    api_key = Rails.application.credentials.dig(:openai, :api_key) || ENV["OPENAI_API_KEY"]
    return nil unless api_key.present?

    client = OpenAI::Client.new(access_token: api_key)

    prompt = "Please provide a concise 500-character summary of the book titled '#{translation.title}'"
    prompt += " by #{translation.author}" if translation.author.present?
    prompt += ". Focus on the main themes, key insights, and whether it's worth reading. Write in a way that helps readers quickly decide if they want to read this book."

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [ { role: "user", content: prompt } ],
        max_tokens: 200,
        temperature: 0.7
      }
    )

    if response.dig("choices", 0, "message", "content").present?
      summary_text = response.dig("choices", 0, "message", "content").strip
      translation.update!(summary: summary_text)
      update!(ai_summary_cached: true)
      summary_text
    end
  rescue => e
    Rails.logger.error "Failed to generate AI summary for book #{id}: #{e.message}"
    nil
  end
end
