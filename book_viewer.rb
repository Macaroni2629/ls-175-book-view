require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def in_paragraphs(array)
    array.map.with_index do |paragraph, index|
     "<p id='a#{index}'>" + paragraph + "</p>"
    end.join
  end

  def make_hash_of_matches
    hash_final = {}
    @toc.each do |chapter_title|
      hash_final[chapter_title] = []
    end
    hash_final
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "Sherlock Holmes"
  @toc = File.read "data/toc.txt"
  @toc = @toc.split("\n")
  erb :home
end

get "/chapters/:number" do 
  x = params[:number]
  toc2 = File.readlines "data/toc.txt"
  @title = "Chapter #{params[:number]} #{toc2[x.to_i - 1]} "
  @toc = File.readlines "data/toc.txt"

  #redirect "/" unless (1..@toc.size).cover? x

  @chapter = File.read "data/chp#{params[:number]}.txt"
  @chapter = @chapter.split("\n\n")
  @chapter = in_paragraphs(@chapter)
  erb :chapter
end

get "/search" do
  @toc = File.readlines "data/toc.txt" #array of chapter titles
  @hash_of_chapter_name_and_num = {} #hash of chapter titles and numbers
  range_of_chapters = (1..12)
  @hash_of_matches = make_hash_of_matches()
  @hash_of_paragraphnum_and_chapter = make_hash_of_matches()

  range_of_chapters.each do |num|

    @chapter = File.read "data/chp#{num}.txt" #the text of the chapter in a string
    @title = @toc[num - 1] #Title of the chapter

    if params[:query] != nil
      if @chapter.include?(params[:query])
        @array_of_paragraphs = @chapter.split("\n\n") #array of paragraphs
        @array_of_paragraphs.each_with_index do |paragraph, index|
          if paragraph.include?(params[:query])
            @hash_of_matches[@title] << paragraph
            @hash_of_paragraphnum_and_chapter[@title] << index
          end
          @hash_of_chapter_name_and_num[@title] = num
        end
      end
    end
    @nothing = "Results not found"
  end
  erb :search

end
=begin
  My problem is I need to bold the phrase within the paragraph that has the search text.

=end