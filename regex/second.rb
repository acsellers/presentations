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
  def match(regex, text)
    if regex.current == '^'
      return match_here(regex.inc, text) 
    end

    loop do
      return true if match_here(regex, text)
      return if text.inc! == Window::EOF
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
  def match_here(regex, text)
    return true if regex.exhausted?

    if text.incomplete? && regex.current == text.current
      match_here(regex.inc, text.inc)
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

  def test_anchored_matches
    # STARTTEST OMIT
    r = Rubex.new("^s")
    %w{ s siri snakes sassafras }.each do |item|
      assert(r.match_string(item), "Matching (^): #{item}")
    end
    %w{ pies Stallone 51 }.each do |item|
      assert(!r.match_string(item), "Not Matching (^): #{item}")
    end
    # STOPTEST OMIT
  end
end
