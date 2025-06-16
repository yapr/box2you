class BooksController < ApplicationController
  before_action :set_book, only: [:show]
  
  def index
    books_query = Book.joins(:book_translations)
                     .where(book_translations: { language: current_language })
                     .popular
    
    @pagy, @books = pagy(books_query, items: 12)
  end

  def show
    @translation = @book.translation_for(current_language)
    
    # Generate AI summary if not cached
    if @translation && !@book.ai_summary_cached?
      @book.generate_ai_summary!(current_language)
      @translation.reload
    end
  end

  def search
    if params[:q].present?
      translations_query = BookTranslation.search_by_title(params[:q])
                                          .in_language(current_language)
                                          .includes(:book)
      
      @pagy, @translations = pagy(translations_query, items: 20)
      @books = @translations.map(&:book)
    else
      @books = []
      @pagy = nil
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @translations }
    end
  end
  
  private
  
  def set_book
    @book = Book.find(params[:id])
  end
  
  def current_language
    'en' # For now, only English
  end
end
