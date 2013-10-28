# PRELUDE OMIT
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
# PRELUDE OMIT
# STARTIMPL OMIT
class Rubex
  def initialize(pattern) # saves pattern for multiple uses
    @pattern = pattern # OMIT
  end # OMIT
 # OMIT
  def match_string(text) # calls match with pattern and text
    match(Window.new(@pattern), Window.new(text)) # OMIT
  end # OMIT

  private # OMIT
  def match(regex, text)
    loop do
      return true if match_here(regex, text)
      return if text.inc! == Window::EOF
    end
  end

  def match_here(regex, text)
    return true if regex.exhausted?

    if text.incomplete? && (regex.current == text.current || regex.current == ".")
      match_here(regex.inc, text.inc)
    end
  end
end
# STOPIMPL OMIT

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
  # STARTTEST OMIT
  def test_empty_string_regex
    r = Rubex.new("")
    %w{ frist sheep 234223 andrew }.each do |item|
      assert(r.match_string(item))
    end
  end
  def test_substring_match
    r = Rubex.new("st")
    %w{ st first steer 21st }.each do |item|
      assert(r.match_string(item), "Matching: #{item}")
    end
    %w{ andrew 213420982 s Starlite}.each do |item|
      assert(!r.match_string(item), "Matching: #{item}")
    end
  end
  def test_dot_match
    r = Rubex.new("s.")
    %w{ st sw exhaust 21st> }.each do |item|
      assert(r.match_string(item), "Matching: #{item}")
    end
    %w{ s andrew 213420982 billies }.each do |item|
      assert(!r.match_string(item), "Matching: #{item}")
    end
  end
  # STOPTEST OMIT
end
