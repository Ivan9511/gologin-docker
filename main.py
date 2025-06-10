from browser_starter import GoLoginManager, BrowserManager

def main():
    profile_id = "YOUR_PROFILE_ID"
    api_token = "YOUR_GOLOGIN_TOKEN"
    port = 13954


    gologin_manager = GoLoginManager(profile_id, api_token, port)
    profile_url = gologin_manager.start_profile()
    
    if not profile_url:
        print("Не удалось запустить профиль GoLogin.")
        exit(1)

    try:
        print(f"[DEBUG] Profile debugger address: {profile_url}")
        browser_manager = BrowserManager(profile_url)
        browser_manager.initialize_browser()

        if not browser_manager.driver:
            print('not driver')

        
        browser_manager.driver.get("about:blank")
        if browser_manager.driver.title == "":
            print("Browser success start")
        else:
            print("Browser start error")
            exit(1)


    except Exception as e:
        print(f'main Exception: {e}')
    finally:
        browser_manager.quit_browser()
        gologin_manager.stop_profile()


if __name__ == "__main__":
    main()