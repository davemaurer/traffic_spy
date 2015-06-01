require_relative '../test_helper'
require 'tilt/erb'

class ViewErrorsTest < FeatureTest
  def setup
    post '/sources', {identifier: "jumpstartlab", rootUrl: "http://jumpstartlab.com"}
    post '/sources', {identifier: "facebook", rootUrl: "http://facebook.com"}
    post 'sources/jumpstartlab/data', 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"referredBy":"http://jumpstartlab.com","requestType":"GET","parameters":[],"eventName":"socialLogin","userAgent":"Mozilla/5.0 (Macintosh%3B Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","resolutionWidth":"1920","resolutionHeight":"1280","ip":"63.29.38.211"}'
  end

  def test_viewing_unknown_source
    visit "/sources/jumpstartla"

    assert page.has_content? "The Identifier 'jumpstartla' does not exist."
  end

  def test_viewing_undefined_event
    visit "/sources/jumpstartlab/urls/blogg"

    assert page.has_content? "The path '/blogg' has not been requested"
  end

  def  test_no_events_defined_error
    visit "/sources/facebook/events"

    assert page.has_content? "No Events have been defined"
  end

  def test_events_page_w_no_source
    visit "/sources/faceboo/events"

    assert page.has_content? "The Identifier 'faceboo' does not exist."
  end

  def test_404
    visit "/random"

    assert page.has_content? "404 : Page not found"
  end
end
