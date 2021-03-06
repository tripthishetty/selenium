require "json"
require "selenium-webdriver"
require "rspec"
require "yaml"
include RSpec::Expectations

describe "SecurityTestAccessDenialToAnotherCommunity" do

  before(:each) do
  @config = YAML.load_file("config_smiley.yml")
    @driver = Selenium::WebDriver.for :firefox
    @base_url = @config['security']['member_base_url']
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  after(:each) do
    #@driver.quit
    @verification_errors.should == []
  end
  
  it "test_security_test_access_denial_to_another_community" do
    #Signin into a community as an admin
    @driver.get(@base_url + "/home")
    @driver.find_element(:id, "member_email").clear
    @driver.find_element(:id, "member_email").send_keys @config['security']['member_email']
	sleep(2)
    @driver.find_element(:id, "member_password").clear
    @driver.find_element(:id, "member_password").send_keys @config['security']['member_pass']
	sleep(2)
    @driver.find_element(:name, "commit").click
	sleep(2)
	#Get the authentication token when the member logs in the first time
	auth = @driver.find_element(:xpath, "//meta[@name='csrf-token']")
	token1 = auth.attribute("content")
	puts "The authentication token when the member logged in the first time: #{token1} "
	sleep(2)
	#logout the first time
	@driver.find_element(:css, "a.header-logout").click
	sleep(2)
	#login the second time
	@driver.get(@base_url + "/home")
    @driver.find_element(:id, "member_email").clear
    @driver.find_element(:id, "member_email").send_keys @config['security']['member_email']
	sleep(2)
    @driver.find_element(:id, "member_password").clear
    @driver.find_element(:id, "member_password").send_keys @config['security']['member_pass']
	sleep(2)
    @driver.find_element(:name, "commit").click
	sleep(2)
	#Get the authentication token when the member logs in the second time
	auth = @driver.find_element(:xpath, "//meta[@name='csrf-token']")
	token2 = auth.attribute("content")
	puts "The authentication token when the member logged in the second time: #{token2} "
	sleep(2)
	#logout the second time
	@driver.find_element(:css, "a.header-logout").click
	sleep(2)
	if(token1==token2)
	puts "The tokens are same. Hence, the test failed."
	else
	puts "The tokens are different. Hence, the test passed."
	end
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
  puts "Logout button does not appear. This confirms the session terminates after the logout and the test is successful."
    false
  end
  
  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
