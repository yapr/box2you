# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating sample books with AI summaries..."

# Popular business and self-help books
books_data = [
  {
    isbn: "9781847941831",
    title: "Atomic Habits",
    author: "James Clear",
    popularity_score: 95,
    summary: "A practical guide to building good habits and breaking bad ones through small, incremental changes. Clear explains how tiny improvements compound over time, making habits the foundation of remarkable results. The book provides a proven framework for creating positive change in your life."
  },
  {
    isbn: "9780684833958",
    title: "The 7 Habits of Highly Effective People",
    author: "Stephen R. Covey",
    popularity_score: 90,
    summary: "A timeless classic that presents seven powerful principles for personal and professional effectiveness. Covey emphasizes character development over quick fixes, teaching readers to be proactive, prioritize effectively, and seek win-win solutions. Essential reading for anyone seeking meaningful success."
  },
  {
    isbn: "9780307474728",
    title: "Sapiens: A Brief History of Humankind",
    author: "Yuval Noah Harari",
    popularity_score: 88,
    summary: "A fascinating exploration of human history from the Stone Age to the present. Harari examines how Homo sapiens conquered the world through cognitive, agricultural, and scientific revolutions. The book challenges assumptions about progress and offers insights into humanity's future."
  },
  {
    isbn: "9781612680194",
    title: "Rich Dad Poor Dad",
    author: "Robert T. Kiyosaki",
    popularity_score: 85,
    summary: "A revolutionary approach to money and investing that challenges conventional wisdom. Kiyosaki contrasts lessons from his 'rich dad' and 'poor dad' to reveal why the wealthy get richer. The book emphasizes financial education and building assets over relying on traditional employment."
  },
  {
    isbn: "9780307887894",
    title: "The Lean Startup",
    author: "Eric Ries",
    popularity_score: 82,
    summary: "A methodology for developing businesses and products through validated learning and iterative design. Ries introduces the Build-Measure-Learn feedback loop and emphasizes creating a minimum viable product. Essential for entrepreneurs and innovators looking to reduce waste and accelerate growth."
  },
  {
    isbn: "9781455586691",
    title: "Deep Work",
    author: "Cal Newport",
    popularity_score: 80,
    summary: "A compelling argument for the value of focused, distraction-free work in our hyper-connected world. Newport shows how deep work is becoming increasingly rare and valuable, providing strategies to cultivate this skill. A must-read for anyone wanting to thrive in the knowledge economy."
  },
  {
    isbn: "9780143126560",
    title: "Thinking, Fast and Slow",
    author: "Daniel Kahneman",
    popularity_score: 87,
    summary: "A groundbreaking exploration of the two systems that drive human thinking: fast, intuitive System 1 and slow, deliberative System 2. Nobel laureate Kahneman reveals cognitive biases and how they affect decision-making. This book fundamentally changes how you understand your own mind."
  },
  {
    isbn: "9780547928227",
    title: "The Power of Habit",
    author: "Charles Duhigg",
    popularity_score: 83,
    summary: "An exploration of the science behind habit formation and how to harness this knowledge for personal and organizational change. Duhigg explains the habit loop and provides practical strategies for transformation. Shows how understanding habits can unlock extraordinary results."
  }
]

books_data.each do |book_data|
  # Find or create book
  book = Book.find_or_create_by(isbn: book_data[:isbn]) do |b|
    b.popularity_score = book_data[:popularity_score]
    b.ai_summary_cached = true
  end
  
  # Create English translation
  translation = book.book_translations.find_or_create_by(language: 'en') do |t|
    t.title = book_data[:title]
    t.author = book_data[:author]
    t.summary = book_data[:summary]
  end
  
  puts "Created/Updated: #{book_data[:title]} by #{book_data[:author]}"
end

puts "✅ Sample data created successfully!"
puts "Total books: #{Book.count}"
puts "Total translations: #{BookTranslation.count}"
