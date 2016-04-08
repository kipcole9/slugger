defmodule Slugger do

  # Default char separating
  @separator_char ?-

  # File that contains the char replacements.
  @replacement_file "replacements.exs"

  # Telling Mix to recompile this file, if the replacement file changed.
  @external_resource "lib/" <> @replacement_file

  @moduledoc """
  Calcualtes a 'slug' for a given string.
  Such a slug can be used for reading URLs or Search Engine Optimization.
  """

  @doc """
  Return a string in form of a slug for a given string.
  
  ## Examples
      
      iex> Slugger.slugify(" Hi # there ")
      "Hi-there"
      
      iex> Slugger.slugify("Über den Wölkchen draußen im Tore")
      "Ueber-den-Woelkchen-draussen-im-Tore"
      
      iex> Slugger.slugify("Wikipedia Style", ?_)
      "Wikipedia_Style"
      
      iex> Slugger.slugify("_Trimming_and___Removing_inside___")
      "Trimming-and-Removing-inside"
    
  """
  def slugify(text, separator \\ @separator_char) do
    text
    |> replace_non_latin_chars
    |> remove_unwanted_chars(separator, ~r/([^A-Za-z0-9])+/)
  end
  
  @doc """
  Return a string in form of a lowercase slug for a given string.
  
  ## Examples
      
      iex> Slugger.slugify_downcase(" Hi # there ")
      "hi-there"
      
      iex> Slugger.slugify_downcase("Über den Wölkchen draußen im Tore")
      "ueber-den-woelkchen-draussen-im-tore"
      
      iex> Slugger.slugify_downcase("Wikipedia Style", ?_)
      "wikipedia_style"
      
      iex> Slugger.slugify_downcase("_trimming_and___removing_inside___")
      "trimming-and-removing-inside"
      
  """
  def slugify_downcase(text, separator \\ @separator_char) do
    text
    |> replace_non_latin_chars
    |> String.downcase
    |> remove_unwanted_chars(separator, ~r/([^a-z0-9])+/)
  end
  
  defp remove_unwanted_chars(text, separator, pattern) do
    text
    |> String.replace(pattern, to_string([separator])) 
    |> String.strip(separator)
  end
  
  defp replace_non_latin_chars(text) do
    text |> to_char_list |> replace_chars |> to_string
  end
  
  #-- Generated function `replace_chars` below --- 
  
  # Generate replacement functions using pattern matching.   
  {replacements, _} = Code.eval_file(@replacement_file, __DIR__)
  for {search, replace} <- replacements do
    if search != @separator_char do
      defp replace_chars([unquote(search)|t]), do: unquote(replace) ++ replace_chars(t)
    end
  end
  
  # And also generate for Chinese to pinyin mappings.  Note these may be fine for
  # slugs but won't include tonemarks.  Also it wont map in a manner predictable
  # to Japanese speakers (Kanji pronunciation is different) or Korean speakers.
  # Note that there are 25,000 of these so not completely sure this is the right strategy
  filename = Path.expand("../data/chinese.dat", __DIR__)
  Enum.each File.stream!(filename, [:utf8]), fn(line) ->
    [search | [replace | _]] = String.split(line, ~r/[ 0-9]/)
    [char | _] = String.to_char_list(search)
    replace = String.to_char_list(replace)
    if search != @separator_char do
      # IO.write to_string(search)
      defp replace_chars([unquote(char)|t]), do: unquote(replace) ++ replace_chars(t)
    end
  end

  # A unmatched char will be kept.
  defp replace_chars([h|t]), do: [h] ++ replace_chars(t)

  # String has come to an end, stop recursion here.
  defp replace_chars([]), do: []

end
