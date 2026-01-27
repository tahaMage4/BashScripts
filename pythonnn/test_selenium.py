import sys
import csv
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException
import time

# Read URL and output file from arguments
url = sys.argv[1]
output_file = sys.argv[2]
# chromedriver_path = '/usr/local/bin/chromedriver'

# Set up Selenium with ChromeDriver
# chrome_options = Options()
# chrome_options.add_argument("--headless")
# chrome_options.add_argument("--disable-gpu")
# service = Service(chromedriver_path)
# driver = webdriver.Chrome(service=service, options=chrome_options)

# Set Firefox options
firefox_options = Options()
firefox_options.headless = True  # Run in headless mode
# Set GeckoDriver path (optional if it's in your PATH)
geckodriver_path = '/snap/bin/geckodriver'

# Initialize Firefox WebDriver
service = Service(geckodriver_path)
driver = webdriver.Firefox(service=service, options=firefox_options)

def take_screenshot(issue_details):
    timestamp = int(time.time())
    screenshot_file = f"screenshot_{timestamp}.png"
    driver.save_screenshot(screenshot_file)
    return screenshot_file

def log_issue(test_type, details):
    screenshot_file = take_screenshot(details)
    with open(output_file, mode='a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([url, test_type, "Failed", details, screenshot_file])

try:
    driver.get(url)
    time.sleep(3)  # Wait for the page to load

    # Check for CSS issues (basic check for missing CSS files)
    css_files = driver.find_elements(By.XPATH, "//link[@rel='stylesheet']")
    for css in css_files:
        css_url = css.get_attribute('href')
        driver.get(css_url)
        if driver.title == "":  # Assuming empty title indicates failure
            log_issue("CSS", f"CSS file failed to load: {css_url}")

    driver.get(url)  # Navigate back to the main URL
    time.sleep(3)

    # Check for JS issues (basic check for console errors)
    logs = driver.get_log('browser')
    for entry in logs:
        if entry['level'] == 'SEVERE':
            log_issue("JavaScript", entry['message'])

    # Example 1: Form Submission Test
    try:
        driver.find_element(By.ID, 'form_id').submit()
        time.sleep(3)  # Wait for success message or element after form submission
        success_message = driver.find_element(By.ID, 'success_message').text
        if "Success" in success_message:
            print("Form submission test passed")
        else:
            log_issue("Form Submission", "Form submission failed: Success message not found")
    except NoSuchElementException as e:
        log_issue("Form Submission", f"Form submission failed: {e}")

    # Example 2: Navigation Test
    try:
        driver.find_element(By.LINK_TEXT, 'About Us').click()
        time.sleep(3)  # Wait for the page to load
        if driver.current_url == "https://example.com/about":
            print("Navigation test to About Us page passed")
        else:
            log_issue("Navigation", "Navigation to About Us page failed")
    except NoSuchElementException as e:
        log_issue("Navigation", f"Navigation to About Us page failed: {e}")

    # Example 3: Element Visibility Test
    try:
        element = driver.find_element(By.ID, 'important_element_id')
        if element.is_displayed():
            print("Important element is visible")
        else:
            log_issue("Visibility", "Important element is not visible")
    except NoSuchElementException as e:
        log_issue("Visibility", f"Important element not found: {e}")

    # Example 4: Performance Test
    start_time = time.time()
    driver.get(url)
    end_time = time.time()
    load_time = end_time - start_time
    print(f"Page load time: {load_time} seconds")
    # Optionally, log load_time if it exceeds a threshold

    # Example 5: Content Validation Test
    expected_content = "Welcome to our website"
    try:
        page_content = driver.find_element(By.TAG_NAME, 'body').text
        if expected_content in page_content:
            print("Content validation passed")
        else:
            log_issue("Content Validation", f"Expected content '{expected_content}' not found")
    except NoSuchElementException as e:
        log_issue("Content Validation", f"Content validation failed: {e}")

finally:
    driver.quit()
