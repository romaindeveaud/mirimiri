#!/usr/bin/env ruby

require 'test/unit'

require 'string'

class TestString < Test::Unit::TestCase

  def test_extract_xml
    s = "four-piece in <a>Indianapolis</a>, <a>Indiana</a> at the Murat Theatre"
    assert_equal(["Indianapolis", "Indiana"],s.extract_xmltags_values('a'))
  end

  def test_stopword
    assert_equal(true, "is".is_stopword?)
    assert_equal(true, "seen".is_stopword?)
    assert_equal(false, "totally".is_stopword?)
    assert_equal(false, "Paris".is_stopword?)
  end

  def test_strip_xml
    assert_equal("testme", "<test>testme</test>".strip_xml_tags)
  end

  def test_strip_punctuation
    assert_equal("test test test test   test test", "test, test. .test, ;test !! ? test ...test./".strip_punctuation)
  end
end
