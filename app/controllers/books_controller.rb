class BooksController < ApplicationController
  before_action :set_book, only: [:show]
  
  def index
    @books = Book.joins(:book_translations)
                 .where(book_translations: { language: current_language })
                 .popular
                 .page(params[:page])
                 .limit(20)
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
      @translations = BookTranslation.search_by_title(params[:q])
                                   .in_language(current_language)
                                   .includes(:book)
                                   .limit(20)
      @books = @translations.map(&:book)
    else
      @books = []
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
