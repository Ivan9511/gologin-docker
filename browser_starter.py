import os
from gologin import GoLogin
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
import traceback

class GoLoginManager:
    def __init__(self, profile_id, api_token, port):
        """
        Args:
            profile_id (str): ID профиля GoLogin.
            api_token (str): Токен API GoLogin.
            port (int): Порт, на котором будет запущен браузер.
        """
        self.profile_id = profile_id
        self.api_token = api_token
        self.port = port
        self.gl = None

    def start_profile(self):
        """
        Returns:
            profile_url
        """
        assert self.api_token is not None, "api_token is None"
        assert self.profile_id is not None, "profile_id is None"
        assert self.port is not None, "port is None"

        try:
            # актуально для gologin==2025.6.2121151
            self.gl = GoLogin({
                "token": self.api_token,
                "profile_id": self.profile_id,
                "port": self.port,
                "executable_path": "/usr/bin/orbita-browser/chrome",
                "extra_params": [
                    "--start-maximized",
                    "--disable-dev-shm-usage",
                    "--no-sandbox",
                    "--no-zygote",
                    "--window-position=0,0"
                ],
                "cleaningLocalCookies": True,
                "autoUpdateBrowser": False,
                "proxy": None
            })
            profile_url = self.gl.start()
            if not profile_url:
                raise Exception("Failed to start GoLogin profile")
            print(f"GoLogin started with WebSocket URL: {profile_url}")
            return profile_url
        except Exception as e:
            print(f"Error starting GoLogin: {e}")
            traceback.print_exc()
            return None

    def stop_profile(self):
        if self.gl:
            try:
                self.gl.stop()
                print("GoLogin profile stopped")
            except Exception as e:
                print(f"Error stopping GoLogin: {e}")

class BrowserManager:
    def __init__(self, profile_url):
        """
        Args:
            profile_url (str): URL WebSocket для подключения к профилю GoLogin.
        """
        self.profile_url = profile_url
        self.driver = None

    def initialize_browser(self):
        """
        Returns:
            WebDriver: Объект WebDriver или None в случае ошибки.
        """
        try:
            if not os.path.exists("/usr/bin/orbita-browser/chromedriver"):
                raise FileNotFoundError("Chromedriver not found at /usr/bin/orbita-browser/chromedriver")
            options = Options()
            options.add_experimental_option("debuggerAddress", self.profile_url)
            options.binary_location = "/usr/bin/orbita-browser/chrome"
            options.add_argument("--no-sandbox")
            options.add_argument("--disable-notifications")
            options.add_argument("--disable-dev-shm-usage")
            service = Service("/usr/bin/orbita-browser/chromedriver")
            self.driver = webdriver.Chrome(service=service, options=options)
            print("Browser initialized successfully")
            return self.driver
        except Exception as e:
            print(f"Error initializing browser: {e}")
            return None

    def quit_browser(self):
        if self.driver:
            try:
                self.driver.quit()
                print("Browser closed")
            except Exception as e:
                print(f"Error quitting browser: {e}")