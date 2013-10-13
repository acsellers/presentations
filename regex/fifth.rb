gem "minitest"
require "minitest/autorun"

class Window
  EOF = -1

  def initialize(text)
    @current = 0
    @text = text
  end

  def inc(n=1)
    (dupe = self.dup).inc!(n)
    dupe
  end

  def inc!(n=1)
    @current += n
    @current == @text.length ? Window::EOF : current
  end

  def current
    @current < @text.length ? @text[@current] : Window::EOF
  end

  def coming
    @current + 1 < @text.length ? @text[@current+1] : Window::EOF
  end

  def exhausted?
    @current == @text.length
  end

  def incomplete?
    @current < @text.length
  end
end

  # STARTCHANGES OMIT
class Rubex
  def match_here(regex, text)
    return true if regex.exhausted?

    if regex.coming == '*'
      match_star(regex.current, regex.inc(2), text)
    elsif regex.coming == '+'
      if regex.current == text.current || regex.current == '.'
        match_star(regex.current, regex.inc(2), text.inc)
      end
    elsif regex.current == '$' && regex.coming == Window::EOF
      text.exhausted?
    elsif text.incomplete? && (regex.current == '.' || regex.current == text.current)
      match_here(regex.inc, text.inc)
    end
  end
  # STOPCHANGES OMIT


  def initialize(pattern)
    @pattern = pattern
  end

  def match_string(text)
    match(Window.new(@pattern), Window.new(text))
  end

  private
  def match(regex, text)
    if regex.current == '^'
      return match_here(regex.inc, text) 
    end

    loop do
      return true if match_here(regex, text)
      return if text.inc! == Window::EOF
    end
  end

  def match_star(char, regex, text)
    loop do
      if match_here(regex, text)
        return true
      elsif !(text.incomplete? && (text.current == char || char == '.'))
        return
      else
        text.inc!
      end
    end
  end
end


class TestWindow < Minitest::Test
  def setup
    @window = Window.new("asdf")
  end

  def test_current
    assert_equal(@window.current, "a")
    assert_equal(@window.coming, "s")
  end

  def test_inc
    assert_equal(@window.inc.current,"s")
    d = @window.inc
    d.inc!
    assert_equal(d.current, "d")
  end

  def test_exhausted
    assert(@window.incomplete?)
    assert(@window.inc(4).exhausted?)
  end
end

class TestRubex < Minitest::Test
  def test_empty_string_regex
    r = Rubex.new("")
    %w{ first seconds 234223j andrew }.each do |item|
      assert(r.match_string(item))
    end
  end

  def test_substring_match
    r = Rubex.new("st")
    %w{ st first stars 23st4223j }.each do |item|
      assert(r.match_string(item), "Matching: #{item}")
    end
    %w{ andrew 213420982 STELLAR }.each do |item|
      assert(!r.match_string(item), "Matching: #{item}")
    end
  end

  def test_repeating_matches
    r = Rubex.new("st*")
    %w{ st first sttars 23s4223j }.each do |item|
      assert(r.match_string(item), "Matching: #{item}")
    end
    %w{ andrew 213420982 STELLAR }.each do |item|
      assert(!r.match_string(item), "Matching: #{item}")
    end
    r = Rubex.new("st+")
    %w{ st first sttars 23s4223jst }.each do |item|
      assert(r.match_string(item), "Matching: #{item}")
    end

    %w{ andrew 213420982 STELLAR }.each do |item|
      assert(!r.match_string(item), "Matching: #{item}")
    end

  end

  def test_anchored_matches
    r = Rubex.new("st*$")
    %w{ st first ttars 23s4223js }.each do |item|
      assert(r.match_string(item), "Matching ($): #{item}")
    end
    %w{ andrew st2st13420982 sSTELLAR }.each do |item|
      assert(!r.match_string(item), "Not Matching ($): #{item}")
    end
    r = Rubex.new("^st*")
    %w{st sfirst sttars s23s4223j}.each do |item|
      assert(r.match_string(item), "Matching (^): #{item}")
    end
    %w{ andrew 2st13420982 STELLAR }.each do |item|
      assert(!r.match_string(item), "Not Matching (^): #{item}")
    end
  end
end
