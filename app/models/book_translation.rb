class BookTranslation < ApplicationRecord
  include PgSearch::Model
  
  belongs_to :book
  
  validates :title, presence: true
  validates :language, presence: true
  validates :book_id, uniqueness: { scope: :language }
  
  pg_search_scope :search_by_title,
    against: :title,
    using: {
      tsearch: {
        prefix: true,
        any_word: true,
        dictionary: "english"
      }
    }
  
  scope :in_language, ->(lang) { where(language: lang) }
end
