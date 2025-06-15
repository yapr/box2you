class HomeController < ApplicationController
  def index
    @popular_books = Book.joins(:book_translations)
                        .where(book_translations: { language: 'en' })
                        .popular
                        .limit(6)
  end
end
