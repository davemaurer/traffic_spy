require_relative '../test_helper'
require 'tilt/erb'

class ViewDashboardTest < FeatureTest
  def setup
    post '/sources', {identifier: "jumpstartlab", rootUrl: "http://jumpstartlab.com"}
    post 'sources/jumpstartlab/data', 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"referredBy":"http://jumpstartlab.com","requestType":"GET","parameters":[],"eventName":"socialLogin","userAgent":"Mozilla/5.0 (Macintosh%3B Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","resolutionWidth":"1920","resolutionHeight":"1280","ip":"63.29.38.211"}'
  end

  def test_viewing_dashboard
    visit "/sources/jumpstartlab"

    assert_equal '/sources/jumpstartlab', current_path
    assert page.has_content? "http://jumpstartlab.com/blog"
    assert page.has_content? "socialLogin"
    assert page.has_content? "Macintosh"
    assert page.has_content? "Chrome"
    assert page.has_content? "1920 x 1280"
  end

  def test_viewing_dashboard_json
    visit "/sources/jumpstartlab.json"

    assert_equal '/sources/jumpstartlab/json', current_path
    assert page.has_content? "http://jumpstartlab.com/blog"
    assert page.has_content? "socialLogin"
    assert page.has_content? "Macintosh"
    assert page.has_content? "Chrome"
    assert page.has_content? "1920 x 1280"
  end

  def test_viewing_dashboard_json_undefined
    visit "/sources/jumpstartla.json"

    assert page.has_content? "The Identifier 'jumpstartla' does not exist."
  end

  def test_landing_page
    visit "/"

    assert page.has_content? "Hello, Traffic Spyer"
  end
end
