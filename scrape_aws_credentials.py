# AWS Student Canvas/vocalabs CLI credentials scrapper for ESGI
# pierre.sarret v1.0 2023 05 10 initial release

import os
from dotenv import load_dotenv
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
import re

# Authenticate with AWS Academy Canvas credentials
load_dotenv()
URL = 'https://awsacademy.instructure.com/login/canvas'
EMAIL = os.getenv("EMAIL")
PASSWORD = os.getenv("PASSWORD")

# Set up the web driver
options = webdriver.ChromeOptions()
options.headless = True
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
#options.add_argument("--disable-gpu")
chrome_prefs = {'profile.default_content_setting_values': {'cookies': 1}, 'profile.cookie_controls_mode': 0}
options.add_experimental_option('prefs', chrome_prefs)

driver = webdriver.Chrome(options=options)

# Login to AWS Academy Canvas
driver.get(URL)
driver.find_element(By.NAME, 'pseudonym_session[unique_id]').send_keys(EMAIL)
driver.find_element(By.NAME, 'pseudonym_session[password]').send_keys(PASSWORD)
driver.find_element(By.XPATH, "//input[@id='pseudonym_session_remember_me']").click()
driver.find_element(By.CLASS_NAME, 'Button--login').click()

# Wait for the lab page to load fully
WebDriverWait(driver, 20).until(EC.presence_of_all_elements_located((By.CLASS_NAME, 'ic-DashboardCard__header-title')))

# Browsing through canvas
driver.find_element(By.CLASS_NAME, 'ic-DashboardCard__header-title').click()
WebDriverWait(driver, 20).until(EC.presence_of_all_elements_located((By.CLASS_NAME, 'modules')))

driver.find_element(By.CLASS_NAME, 'modules').click()
WebDriverWait(driver, 20).until(EC.presence_of_all_elements_located((By.XPATH, "//a[@title='Learner Lab']")))

driver.find_element(By.XPATH, "//a[@title='Learner Lab']").click()
WebDriverWait(driver, 60).until(EC.presence_of_all_elements_located((By.NAME, "tool_content")))

# Switch to the vocalabs iframe
driver.switch_to.frame(driver.find_element(By.NAME, "tool_content"))
print("switched to vocalabs iframe")
driver.execute_script("return window.frameElement")
WebDriverWait(driver, 60).until(EC.presence_of_all_elements_located((By.XPATH, "//div[@id='launchclabsbtn']")))

# Starting lab
driver.find_element(By.XPATH, "//div[@id='launchclabsbtn']").click()
WebDriverWait(driver, 60).until(EC.presence_of_all_elements_located((By.ID, "clikeybox")))

# Scrape the web page with BeautifulSoup
soup = BeautifulSoup(driver.page_source, 'html.parser')

# Find the AWS access key, secret key, and session token
clikeybox = soup.select_one('#clikeybox')

# Close the driver
driver.quit()

# == VALUES EXTRACTION ==
print("=== RAW FETCH ===")
print(clikeybox)

print("=== VALUES ===")

clikeybox_text=clikeybox.get_text()
aws_access_key_id = re.search(r'aws_access_key_id=([^\n]+)', clikeybox_text).group(1)
aws_secret_access_key = re.search(r'aws_secret_access_key=([^\n]+)', clikeybox_text).group(1)
aws_session_token = re.search(r'aws_session_token=([^\n]+)', clikeybox_text).group(1)

print("aws_access_key_id=" + aws_access_key_id)
print("aws_secret_access_key=" + aws_secret_access_key)
print("aws_session_token=" + aws_session_token)

# == VAR FILE INSERTION ==
# Replacing values in tfvars
# Read .tfvars file
filename = "terraform.tfvars"
with open(filename, "r") as file:
    content = file.read()

# Replace variables
content = re.sub(r"aws_access_key_id\s*=\s*\"[^\"]*\"", f'aws_access_key_id = "{aws_access_key_id}"', content)
content = re.sub(r"aws_secret_access_key\s*=\s*\"[^\"]*\"", f'aws_secret_access_key = "{aws_secret_access_key}"', content)
content = re.sub(r"aws_session_token\s*=\s*\"[^\"]*\"", f'aws_session_token = "{aws_session_token}"', content)

# Write updated content back to the .tfvars file
with open(filename, "w") as file:
    file.write(content)

content = {}
# Replacing values in ansible aws_ec2
# Read .yml file
filename = "ansible/aws_ec2.yml"
with open(filename, "r") as file:
    content = file.read()

# Replace variables
content = re.sub(r"aws_access_key\s*:\s*\"[^\"]*\"", f'aws_access_key: "{aws_access_key_id}"', content)
content = re.sub(r"aws_secret_key\s*:\s*\"[^\"]*\"", f'aws_secret_key: "{aws_secret_access_key}"', content)
content = re.sub(r"aws_security_token\s*:\s*\"[^\"]*\"", f'aws_security_token: "{aws_session_token}"', content)

# Write updated content back to the .tfvars file
with open(filename, "w") as file:
    file.write(content)