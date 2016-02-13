require 'test_helper'

class NormalizationTest < ActiveSupport::TestCase

  tests = {
    "Hello Can't You See Me" => "Hello Can't You See Me",
    "Hello Can’t You See Me" => "Hello Can't You See Me",
    "Hello Stupid' You See Me" => "Hello Stupid You See Me",
    "Hello ‘Can’ You See Me" => "Hello \"Can\" You See Me",
    "Dumb Butt." => "Dumb Butt",
    "Dumb Butt. " => "Dumb Butt",
    "Pharrell Has a 5'4\" Boyfriend" => "Pharrell Has a 5'4\" Boyfriend",
    "Get \"Frozen\" Again as Elsa Sings \"Let It Flow" => "Get \"Frozen\" Again as Elsa Sings \"Let It Flow",
    "You \"Suck\": She Said" => "You \"Suck\": She Said",
    "You Suck\": She Said" => "You Suck: She Said",
    "Hello Can't You See\" Me" => "Hello Can't You See Me",
    "Hello Can't You \"See\" Me" => "Hello Can't You \"See\" Me",
    "Post-\"Breaking Bad,\" Skyler and Jesse Are Among the World's Biggest Assholes in Greek Mythology" => "Post-\"Breaking Bad,\" Skyler and Jesse Are Among the World's Biggest Assholes in Greek Mythology",
    "\"The Wisdom on Tumblr Is Beyond Sad." => "The Wisdom on Tumblr Is Beyond Sad",
    "Obama: Romney Is 'Pretending He Came Up With \"Bullet-Time\"" => "Obama: Romney Is Pretending He Came Up With \"Bullet-Time\"",
    "How to Dress Like a Train'" => "How to Dress Like a Train",
    "'How to Dress Like a Train" => "How to Dress Like a Train",
    "How to Dress Can't a Train'" => "How to Dress Can't a Train",
    "How to 'Dress' Can't a Train'" => "How to \"Dress\" Can't a Train",
    "\"This is quoted\"" => "This is quoted",
    "'This is quoted'" => "This is quoted",
    "Google+'s Real Goal Is Mars" => "Google+'s Real Goal Is Mars",
    "*GRAPHIC* Disturbing, 78-Second Video Surfaces Claiming to Be 'One of Microsoft's Best E3 Conferences'" => "*GRAPHIC* Disturbing, 78-Second Video Surfaces Claiming to Be One of Microsoft's Best E3 Conferences",
  }

  tests.each do |input, out|
    test "normalizes #{input}" do
      h = Headline.new(name: input)
      rp = h.repunctuated_name
      fr = h.formatted_name
      assert_equal input.length, rp.length, "repunctuation resulted in a mismatched length"
      assert_equal out, fr
    end
  end

end
