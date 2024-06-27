from selenium import webdriver

# Replace with the path to your web driver executable (e.g., chromedriver)
webdriver_path = '/path/to/chromedriver'

# Define the URL of the website to be tested
url = "http://35.163.236.118/"

# Initialize the Selenium WebDriver
driver = webdriver.Chrome(executable_path=webdriver_path)

# Open the website
driver.get(url)

# Find and interact with web elements, e.g., filling a login form
username_input = driver.find_element_by_id("username")
password_input = driver.find_element_by_id("password")

username_input.send_keys("your_username")
password_input.send_keys("your_password")

# Submit the form
login_button = driver.find_element_by_id("login-button")
login_button.click()

# Perform further interactions as needed

# Close the browser window
driver.quit()
