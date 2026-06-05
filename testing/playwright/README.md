# 🎭 Playwright Python  Project
### **E-Commerce Test Automation Suite**

> **Project Theme:** Build a full-scale, production-grade test automation framework for a real e-commerce website ([SauceDemo](https://www.saucedemo.com) + [DemoQA](https://demoqa.com) + [The Internet](https://the-internet.herokuapp.com)) — covering every Playwright concept employers look for.

---

## 📁 Project Structure

```
ecommerce-playwright-suite/
│
├── .github/
│   └── workflows/
│       └── ci.yml                  # GitHub Actions CI/CD Pipeline
│
├── pages/                          # Page Object Model (POM)
│   ├── __init__.py
│   ├── base_page.py
│   ├── login_page.py
│   ├── inventory_page.py
│   ├── cart_page.py
│   └── checkout_page.py
│
├── tests/
│   ├── __init__.py
│   ├── conftest.py                 # Fixtures & Hooks
│   ├── test_login.py
│   ├── test_inventory.py
│   ├── test_cart.py
│   ├── test_checkout.py
│   ├── test_api.py                 # API Testing with Playwright
│   ├── test_visual.py              # Visual / Screenshot Testing
│   ├── test_network.py             # Network Interception
│   └── test_advanced.py            # Advanced concepts
│
├── utils/
│   ├── __init__.py
│   ├── helpers.py
│   └── data_factory.py             # Faker-based test data
│
├── test_data/
│   ├── users.json
│   └── products.json
│
├── reports/                        # Auto-generated (gitignored)
├── screenshots/                    # Auto-generated (gitignored)
│
├── playwright.config.py            # Global Playwright config
├── conftest.py                     # Root conftest
├── requirements.txt
├── .env.example
├── .gitignore
└── README.md
```

---

## 🧩 Tasks Overview

| Task | Topic  |
|------|-------|
| [Task 1](#task-1--project-setup--environment) | Setup & Installation |
| [Task 2](#task-2--first-test--browser-basics) | First Test & Browser Basics|
| [Task 3](#task-3--locators--selectors-mastery) | Locators & Selectors  |
| [Task 4](#task-4--page-object-model-pom) | Page Object Model (POM)  |
| [Task 5](#task-5--fixtures--conftest) | Fixtures & conftest.py  |
| [Task 6](#task-6--assertions--expect-api) | Assertions & Expect API  |
| [Task 7](#task-7--handling-dynamic-elements) | Waits & Dynamic Elements |
| [Task 8](#task-8--network-interception--mocking) | Network Interception & Mocking  |
| [Task 9](#task-9--api-testing-with-playwright) | API Testing  |
| [Task 10](#task-10--visual-testing--screenshots) | Visual Testing & Screenshots |
| [Task 11](#task-11--multi-browser--parallel-testing) | Multi-Browser & Parallel Testing  |
| [Task 12](#task-12--cicd-with-github-actions) | CI/CD with GitHub Actions |

---

## Task 1 — Project Setup & Environment

**🎯 Goal:** Set up a professional Python project with virtual environment, install Playwright, and understand the project scaffolding.

### Steps

**1. Create and activate virtual environment**
```bash
python -m venv venv
source venv/bin/activate        # Mac/Linux
venv\Scripts\activate           # Windows
```

**2. Install dependencies**
```bash
pip install playwright pytest pytest-playwright pytest-html \
            python-dotenv faker pytest-xdist allure-pytest
playwright install
```

**3. Create `requirements.txt`**
```
playwright==1.44.0
pytest==8.2.0
pytest-playwright==0.5.0
pytest-html==4.1.1
pytest-xdist==3.5.0
python-dotenv==1.0.1
faker==25.2.0
allure-pytest==2.13.5
```

**4. Create `.env.example`**
```
BASE_URL=https://www.saucedemo.com
USERNAME=standard_user
PASSWORD=secret_sauce
HEADLESS=true
SLOW_MO=0
```

**5. Create `.gitignore`**
```
venv/
__pycache__/
.env
reports/
screenshots/
test-results/
playwright-report/
.pytest_cache/
```

### 💡  Concept
> **Q: What is Playwright and how does it differ from Selenium?**  
> Playwright supports auto-waiting, network interception, multiple browser contexts in one session, and has a modern async/sync API. It doesn't need WebDriver.

---

## Task 2 — First Test & Browser Basics

**🎯 Goal:** Write your first test, understand browser/context/page hierarchy, headless vs headed mode, and screenshots.

### Concepts Covered
- `sync_playwright` vs `async_playwright`
- Browser → BrowserContext → Page hierarchy
- `page.goto()`, `page.title()`, `page.screenshot()`
- Running: `pytest -v` and `pytest --headed`

### Your Task

Create `tests/test_basics.py`:

```python
import pytest
from playwright.sync_api import Page, expect

def test_page_title(page: Page):
    """Verify the login page title is correct."""
    page.goto("https://www.saucedemo.com")
    expect(page).to_have_title("Swag Labs")

def test_page_screenshot(page: Page):
    """Capture a screenshot of the login page."""
    page.goto("https://www.saucedemo.com")
    page.screenshot(path="screenshots/login_page.png", full_page=True)
    assert True  # screenshot saved without error

def test_browser_context_isolation(browser):
    """
    Prove that two browser contexts are completely isolated
    (separate cookies, sessions, local storage).
    """
    context1 = browser.new_context()
    context2 = browser.new_context()

    page1 = context1.new_page()
    page2 = context2.new_page()

    page1.goto("https://www.saucedemo.com")
    page2.goto("https://www.saucedemo.com")

    # Set localStorage in context1 only
    page1.evaluate("localStorage.setItem('test_key', 'hello')")
    value_in_ctx1 = page1.evaluate("localStorage.getItem('test_key')")
    value_in_ctx2 = page2.evaluate("localStorage.getItem('test_key')")

    assert value_in_ctx1 == "hello"
    assert value_in_ctx2 is None  # Isolation confirmed!

    context1.close()
    context2.close()
```

### Run Commands
```bash
pytest tests/test_basics.py -v
pytest tests/test_basics.py -v --headed --slowmo 500
```

### 💡 Concepts
> **Q: Explain the Browser → Context → Page hierarchy.**  
> Browser = the browser process. Context = incognito-like isolated session (own cookies/storage). Page = a single tab. One browser can have many contexts; each context can have many pages.

> **Q: When would you use multiple browser contexts in a test?**  
> Multi-user scenarios, e.g. testing a chat application where User A sends a message and User B receives it — both in the same test, without logging out.

---

## Task 3 — Locators & Selectors Mastery

**🎯 Goal:** Master all Playwright locator strategies. Understand why Playwright recommends role/text locators over CSS/XPath.

### Concepts Covered
- `get_by_role()`, `get_by_text()`, `get_by_label()`, `get_by_placeholder()`
- `get_by_test_id()`, `get_by_title()`, `get_by_alt_text()`
- CSS and XPath as fallbacks
- Chaining locators: `page.locator(".container").get_by_role("button")`
- `locator.nth()`, `locator.first`, `locator.last`
- `locator.filter(has_text=...)`

### Your Task

Create `tests/test_locators.py`:

```python
from playwright.sync_api import Page, expect

def test_locator_by_role(page: Page):
    page.goto("https://www.saucedemo.com")
    # Locate username input by role + name
    username_input = page.get_by_role("textbox", name="Username")
    expect(username_input).to_be_visible()

def test_locator_by_placeholder(page: Page):
    page.goto("https://www.saucedemo.com")
    page.get_by_placeholder("Username").fill("standard_user")
    page.get_by_placeholder("Password").fill("secret_sauce")
    page.get_by_role("button", name="Login").click()
    expect(page).to_have_url("https://www.saucedemo.com/inventory.html")

def test_locator_chaining_and_filter(page: Page):
    """Find a specific product card by filtering with text."""
    page.goto("https://www.saucedemo.com")
    page.get_by_placeholder("Username").fill("standard_user")
    page.get_by_placeholder("Password").fill("secret_sauce")
    page.get_by_role("button", name="Login").click()

    # Chain: inventory list > filter by product name > add to cart
    product_card = page.locator(".inventory_item").filter(
        has_text="Sauce Labs Backpack"
    )
    expect(product_card).to_be_visible()
    product_card.get_by_role("button", name="Add to cart").click()

    cart_badge = page.locator(".shopping_cart_badge")
    expect(cart_badge).to_have_text("1")

def test_nth_locator(page: Page):
    """Get the first and last items in the inventory list."""
    page.goto("https://www.saucedemo.com")
    page.get_by_placeholder("Username").fill("standard_user")
    page.get_by_placeholder("Password").fill("secret_sauce")
    page.get_by_role("button", name="Login").click()

    items = page.locator(".inventory_item_name")
    first_item = items.first
    last_item = items.last

    expect(first_item).to_be_visible()
    expect(last_item).to_be_visible()
    # They should be different products
    assert await_text(first_item) != await_text(last_item)

def await_text(locator):
    return locator.inner_text()
```


### 💡 Concepts
> **Q: Which locator strategy does Playwright recommend and why?**  
> Playwright recommends role-based locators (`get_by_role`) because they mirror how users and screen readers interact with the page — making tests more resilient and accessible-aligned.

> **Q: What's the difference between `locator.filter()` and chaining locators?**  
> `filter()` narrows an existing locator set by a condition (text, child element). Chaining queries within a matched element's scope.

---

## Task 4 — Page Object Model (POM)

**🎯 Goal:** Refactor raw tests into a maintainable Page Object Model — the #1 design pattern in enterprise test automation.

### Concepts Covered
- Why POM? Separation of concerns, DRY principle
- Base page with common methods
- Page classes encapsulating selectors + actions
- Returning page objects from methods (fluent/chaining pattern)

### Your Task

**`pages/base_page.py`**
```python
from playwright.sync_api import Page

class BasePage:
    def __init__(self, page: Page):
        self.page = page

    def navigate(self, url: str):
        self.page.goto(url)
        return self

    def get_title(self) -> str:
        return self.page.title()

    def take_screenshot(self, name: str):
        self.page.screenshot(path=f"screenshots/{name}.png")
```

**`pages/login_page.py`**
```python
from playwright.sync_api import Page, expect
from pages.base_page import BasePage

class LoginPage(BasePage):
    URL = "https://www.saucedemo.com"

    def __init__(self, page: Page):
        super().__init__(page)
        self.username_input = page.get_by_placeholder("Username")
        self.password_input = page.get_by_placeholder("Password")
        self.login_button   = page.get_by_role("button", name="Login")
        self.error_message  = page.locator("[data-test='error']")

    def load(self):
        self.navigate(self.URL)
        return self

    def login(self, username: str, password: str):
        self.username_input.fill(username)
        self.password_input.fill(password)
        self.login_button.click()
        return self

    def get_error_message(self) -> str:
        return self.error_message.inner_text()
```

**`pages/inventory_page.py`**
```python
from playwright.sync_api import Page, expect
from pages.base_page import BasePage

class InventoryPage(BasePage):
    URL = "https://www.saucedemo.com/inventory.html"

    def __init__(self, page: Page):
        super().__init__(page)
        self.cart_icon  = page.locator(".shopping_cart_link")
        self.cart_badge = page.locator(".shopping_cart_badge")
        self.items      = page.locator(".inventory_item")

    def add_item_to_cart(self, item_name: str):
        self.items.filter(has_text=item_name).get_by_role(
            "button", name="Add to cart"
        ).click()
        return self

    def get_cart_count(self) -> int:
        if self.cart_badge.is_visible():
            return int(self.cart_badge.inner_text())
        return 0

    def go_to_cart(self):
        self.cart_icon.click()
        from pages.cart_page import CartPage
        return CartPage(self.page)
```

**`tests/test_login.py`** (refactored with POM)
```python
import pytest
from playwright.sync_api import Page, expect
from pages.login_page import LoginPage
from pages.inventory_page import InventoryPage

def test_valid_login(page: Page):
    login = LoginPage(page).load()
    login.login("standard_user", "secret_sauce")
    expect(page).to_have_url("https://www.saucedemo.com/inventory.html")

def test_invalid_login_shows_error(page: Page):
    login = LoginPage(page).load()
    login.login("invalid_user", "wrong_password")
    assert "Username and password do not match" in login.get_error_message()

def test_locked_out_user(page: Page):
    login = LoginPage(page).load()
    login.login("locked_out_user", "secret_sauce")
    assert "locked out" in login.get_error_message().lower()
```


### 💡 Concepts
> **Q: What is POM and why is it used?**  
> POM separates the UI interaction logic (in page classes) from test assertions. Benefits: reusability, easier maintenance when UI changes (only update the page class, not every test).

---

## Task 5 — Fixtures & conftest.py

**🎯 Goal:** Master pytest fixtures for setup/teardown, shared state, and dependency injection — the backbone of scalable test suites.

### Concepts Covered
- `conftest.py` — auto-discovery by pytest
- Fixture scopes: `function`, `session`, `module`, `class`
- Fixture factories
- `autouse=True`
- Parametrizing fixtures

### Your Task

**`conftest.py`** (root level)
```python
import pytest
import os
from dotenv import load_dotenv
from playwright.sync_api import Page, BrowserContext

load_dotenv()

# ── Credentials fixture (session-scoped — read once) ──────────────────────────
@pytest.fixture(scope="session")
def credentials():
    return {
        "username": os.getenv("USERNAME", "standard_user"),
        "password": os.getenv("PASSWORD", "secret_sauce"),
        "base_url": os.getenv("BASE_URL", "https://www.saucedemo.com"),
    }

# ── Authenticated page fixture ─────────────────────────────────────────────────
@pytest.fixture
def logged_in_page(page: Page, credentials):
    """Provides a page that is already logged in."""
    page.goto(credentials["base_url"])
    page.get_by_placeholder("Username").fill(credentials["username"])
    page.get_by_placeholder("Password").fill(credentials["password"])
    page.get_by_role("button", name="Login").click()
    page.wait_for_url("**/inventory.html")
    yield page
    # Teardown: clear cart after each test
    page.goto(credentials["base_url"] + "/cart.html")

# ── Storage state fixture (advanced: save login session) ──────────────────────
@pytest.fixture(scope="session")
def auth_storage_state(browser, credentials):
    """Login once, save storage state, reuse across all tests."""
    context = browser.new_context()
    page = context.new_page()
    page.goto(credentials["base_url"])
    page.get_by_placeholder("Username").fill(credentials["username"])
    page.get_by_placeholder("Password").fill(credentials["password"])
    page.get_by_role("button", name="Login").click()
    page.wait_for_url("**/inventory.html")
    # Save auth state to file
    context.storage_state(path="auth_state.json")
    context.close()
    return "auth_state.json"
```

**`tests/conftest.py`**
```python
import pytest

# ── Parametrize with multiple users ───────────────────────────────────────────
@pytest.fixture(params=[
    ("standard_user",      "secret_sauce"),
    ("performance_glitch_user", "secret_sauce"),
])
def all_valid_users(request):
    username, password = request.param
    return {"username": username, "password": password}
```

**`tests/test_fixtures_demo.py`**
```python
import pytest
from playwright.sync_api import Page, expect
from pages.inventory_page import InventoryPage

def test_add_to_cart_uses_logged_in_fixture(logged_in_page: Page):
    inv = InventoryPage(logged_in_page)
    inv.add_item_to_cart("Sauce Labs Backpack")
    assert inv.get_cart_count() == 1

def test_all_valid_users_can_login(page: Page, all_valid_users):
    page.goto("https://www.saucedemo.com")
    page.get_by_placeholder("Username").fill(all_valid_users["username"])
    page.get_by_placeholder("Password").fill(all_valid_users["password"])
    page.get_by_role("button", name="Login").click()
    expect(page).to_have_url("**/inventory.html")
```

### ✅ Deliverable
- `logged_in_page` fixture used in at least 5 tests.
- Parametrized user fixture runs tests against both valid users.
- Demonstrate difference between `function` and `session` scope using a print statement.

### 💡 Concepts
> **Q: Explain fixture scope in pytest-playwright.**  
> `function` (default) = fresh browser page per test. `session` = one instance for the entire run. For Playwright, `browser` is `session` scoped but `page` is `function` scoped to ensure test isolation.

---

## Task 6 — Assertions & Expect API

**🎯 Goal:** Use Playwright's built-in `expect()` API for auto-retrying assertions — never write flaky `time.sleep()` tests.

### Concepts Covered
- `expect(locator).to_be_visible()` / `to_be_hidden()`
- `expect(locator).to_have_text()` / `to_contain_text()`
- `expect(locator).to_have_value()` / `to_have_attribute()`
- `expect(locator).to_be_enabled()` / `to_be_disabled()`
- `expect(locator).to_have_count()`
- `expect(page).to_have_url()` / `to_have_title()`
- Negative assertions: `expect(locator).not_to_be_visible()`
- Custom timeout: `expect(locator, timeout=10000).to_be_visible()`

### Your Task

Create `tests/test_assertions.py`:

```python
import pytest
from playwright.sync_api import Page, expect
from pages.login_page import LoginPage
from pages.inventory_page import InventoryPage

def test_inventory_item_count(logged_in_page: Page):
    """There should be exactly 6 products on the inventory page."""
    items = logged_in_page.locator(".inventory_item")
    expect(items).to_have_count(6)

def test_add_to_cart_button_text_changes(logged_in_page: Page):
    """After adding an item, button text should change to 'Remove'."""
    inv = InventoryPage(logged_in_page)
    backpack_card = logged_in_page.locator(".inventory_item").filter(
        has_text="Sauce Labs Backpack"
    )
    add_btn = backpack_card.get_by_role("button")
    expect(add_btn).to_have_text("Add to cart")
    add_btn.click()
    expect(add_btn).to_have_text("Remove")

def test_sort_dropdown_default_value(logged_in_page: Page):
    """Default sort should be 'Name (A to Z)'."""
    sort_select = logged_in_page.locator(".product_sort_container")
    expect(sort_select).to_have_value("az")

def test_cart_badge_not_visible_initially(logged_in_page: Page):
    """Cart badge should not be visible when cart is empty."""
    badge = logged_in_page.locator(".shopping_cart_badge")
    expect(badge).not_to_be_visible()

def test_product_price_format(logged_in_page: Page):
    """All prices should start with a dollar sign."""
    prices = logged_in_page.locator(".inventory_item_price").all()
    for price in prices:
        assert price.inner_text().startswith("$"), f"Price format wrong: {price.inner_text()}"
```

### ✅ Deliverable
- 8+ assertion tests covering all major `expect()` methods listed above.

### 💡 Concepts
> **Q: Why use Playwright's `expect()` over Python's `assert`?**  
> `expect()` has built-in **auto-retry** (default 5s). It keeps re-checking until the assertion passes or times out. Plain `assert` checks once and fails immediately — causing flaky tests on dynamic pages.

---

## Task 7 — Handling Dynamic Elements

**🎯 Goal:** Handle real-world async challenges: waits, popups, dialogs, iframes, file upload/download, hover, drag-and-drop.

### Concepts Covered
- `page.wait_for_selector()`, `page.wait_for_url()`, `page.wait_for_load_state()`
- `page.wait_for_timeout()` — use sparingly!
- Handling `dialog` (alert/confirm/prompt) events
- Working with iframes: `frame_locator()`
- File upload: `set_input_files()`
- File download: `expect_download()`
- Hover: `locator.hover()`
- Drag and drop: `locator.drag_to()`
- New tab / popup: `expect_popup()`

### Your Task

Create `tests/test_dynamic.py` using The Internet Heroku app for varied scenarios:

```python
import pytest
from playwright.sync_api import Page, expect

BASE = "https://the-internet.herokuapp.com"

# ── Dialog Handling ────────────────────────────────────────────────────────────
def test_accept_alert_dialog(page: Page):
    page.goto(f"{BASE}/javascript_alerts")
    page.on("dialog", lambda dialog: dialog.accept())
    page.get_by_role("button", name="Click for JS Alert").click()
    result = page.locator("#result")
    expect(result).to_have_text("You successfuly clicked an alert")

def test_confirm_dialog_dismiss(page: Page):
    page.goto(f"{BASE}/javascript_alerts")
    page.on("dialog", lambda dialog: dialog.dismiss())
    page.get_by_role("button", name="Click for JS Confirm").click()
    expect(page.locator("#result")).to_contain_text("Cancel")

def test_prompt_dialog_fill(page: Page):
    def handle_prompt(dialog):
        dialog.accept("Playwright Master")
    page.goto(f"{BASE}/javascript_alerts")
    page.on("dialog", handle_prompt)
    page.get_by_role("button", name="Click for JS Prompt").click()
    expect(page.locator("#result")).to_contain_text("Playwright Master")

# ── iFrame ─────────────────────────────────────────────────────────────────────
def test_interact_with_iframe(page: Page):
    page.goto(f"{BASE}/iframe")
    frame = page.frame_locator("#mce_0_ifr")
    body = frame.locator("body")
    body.click()
    body.type("Hello from Playwright!")
    expect(body).to_contain_text("Hello from Playwright!")

# ── File Upload ────────────────────────────────────────────────────────────────
def test_file_upload(page: Page, tmp_path):
    # Create a temp file
    upload_file = tmp_path / "test_upload.txt"
    upload_file.write_text("Playwright upload test content")

    page.goto(f"{BASE}/upload")
    page.locator("#file-upload").set_input_files(str(upload_file))
    page.locator("#file-submit").click()
    expect(page.locator("#uploaded-files")).to_have_text("test_upload.txt")

# ── New Tab / Popup ────────────────────────────────────────────────────────────
def test_new_tab_opens(page: Page):
    page.goto(f"{BASE}/windows")
    with page.expect_popup() as popup_info:
        page.get_by_role("link", name="Click Here").click()
    new_page = popup_info.value
    new_page.wait_for_load_state()
    expect(new_page).to_have_url(f"{BASE}/windows/new")

# ── Hover ──────────────────────────────────────────────────────────────────────
def test_hover_reveals_element(page: Page):
    page.goto(f"{BASE}/hovers")
    avatars = page.locator(".figure")
    first_avatar = avatars.first
    first_avatar.hover()
    caption = first_avatar.locator(".figcaption")
    expect(caption).to_be_visible()
```

### ✅ Deliverable
- All dynamic element tests passing. Add a drag-and-drop test using DemoQA's drag-and-drop page as a bonus.

---

## Task 8 — Network Interception & Mocking

**🎯 Goal:** Intercept, modify, and mock network requests — a powerful technique for isolating front-end tests from back-end dependencies.

### Concepts Covered
- `page.route()` — intercept requests
- `route.fulfill()` — mock response
- `route.abort()` — block requests
- `route.continue_()` — pass through (with optional modifications)
- `page.expect_request()` / `page.expect_response()`
- Mocking API responses with custom JSON

### Your Task

Create `tests/test_network.py`:

```python
import json
import pytest
from playwright.sync_api import Page, Route, expect

REQRES_BASE = "https://reqres.in"

# ── Mock a REST API response ───────────────────────────────────────────────────
def test_mock_api_response(page: Page):
    """Intercept a GET request and return mocked data."""
    mock_users = {
        "data": [
            {"id": 99, "email": "mock@test.com", "first_name": "Mock", "last_name": "User"}
        ]
    }

    page.route("**/api/users*", lambda route: route.fulfill(
        status=200,
        content_type="application/json",
        body=json.dumps(mock_users)
    ))

    page.goto(f"{REQRES_BASE}/api/users?page=1")
    content = page.locator("pre").inner_text()
    data = json.loads(content)
    assert data["data"][0]["id"] == 99
    assert data["data"][0]["first_name"] == "Mock"

# ── Block image requests ───────────────────────────────────────────────────────
def test_block_images(page: Page):
    """Block all PNG/JPG images to speed up page load."""
    page.route("**/*.{png,jpg,jpeg,gif,svg}", lambda route: route.abort())
    page.goto("https://www.saucedemo.com/inventory.html")
    # Images are blocked — check page still loads
    expect(page.locator(".inventory_item")).to_have_count(0)  # not logged in, redirect happens

# ── Intercept and modify request headers ──────────────────────────────────────
def test_modify_request_headers(page: Page):
    """Add a custom header to every request."""
    def add_custom_header(route: Route):
        headers = {**route.request.headers, "X-Test-Header": "playwright"}
        route.continue_(headers=headers)

    page.route("**/*", add_custom_header)
    page.goto("https://www.saucedemo.com")
    expect(page).to_have_title("Swag Labs")

# ── Assert request was made ────────────────────────────────────────────────────
def test_expect_specific_request(page: Page, logged_in_page: Page):
    """Verify a specific API call is made when an action happens."""
    # Monitor for any XHR/fetch call
    with logged_in_page.expect_response("**/*") as resp_info:
        logged_in_page.locator(".inventory_item").first.locator("img").click()
    # Just asserting the page responded
    assert resp_info.value.status < 400
```

### ✅ Deliverable
- Mock, block, and modify network requests. Add a test that simulates an API returning a 500 error and verifies the UI shows an error state.

### 💡 Concepts
> **Q: Why would you mock API responses in UI tests?**  
> To isolate the front-end from the back-end. Prevents test failures caused by API downtime, eliminates slow real API calls, lets you test edge cases (500 errors, empty data) that are hard to reproduce with real backends.

---

## Task 9 — API Testing with Playwright

**🎯 Goal:** Use Playwright's `APIRequestContext` to write API tests — enabling a combined API + UI testing strategy.

### Concepts Covered
- `playwright.request.new_context()`
- `api_request_context.get()`, `.post()`, `.put()`, `.delete()`
- Asserting status codes, response bodies, headers
- Reusing API auth token in UI tests (API login → UI test)
- `pytest.fixture` for reusable API client

### Your Task

Create `tests/test_api.py`:

```python
import pytest
import json
from playwright.sync_api import Playwright, APIRequestContext

REQRES_BASE = "https://reqres.in"

@pytest.fixture(scope="module")
def api_client(playwright: Playwright) -> APIRequestContext:
    request_context = playwright.request.new_context(
        base_url=REQRES_BASE,
        extra_http_headers={"Content-Type": "application/json"}
    )
    yield request_context
    request_context.dispose()

# ── GET ────────────────────────────────────────────────────────────────────────
def test_get_users_returns_200(api_client: APIRequestContext):
    response = api_client.get("/api/users?page=2")
    assert response.status == 200
    body = response.json()
    assert "data" in body
    assert len(body["data"]) > 0

def test_get_single_user(api_client: APIRequestContext):
    response = api_client.get("/api/users/2")
    assert response.status == 200
    user = response.json()["data"]
    assert user["id"] == 2
    assert "email" in user

def test_get_nonexistent_user_returns_404(api_client: APIRequestContext):
    response = api_client.get("/api/users/9999")
    assert response.status == 404

# ── POST ───────────────────────────────────────────────────────────────────────
def test_create_user(api_client: APIRequestContext):
    payload = {"name": "Playwright Tester", "job": "QA Engineer"}
    response = api_client.post("/api/users", data=json.dumps(payload))
    assert response.status == 201
    body = response.json()
    assert body["name"] == "Playwright Tester"
    assert "id" in body
    assert "createdAt" in body

def test_login_returns_token(api_client: APIRequestContext):
    payload = {"email": "eve.holt@reqres.in", "password": "cityslicka"}
    response = api_client.post("/api/login", data=json.dumps(payload))
    assert response.status == 200
    assert "token" in response.json()

# ── PUT / PATCH / DELETE ───────────────────────────────────────────────────────
def test_update_user_put(api_client: APIRequestContext):
    payload = {"name": "Updated Name", "job": "Senior QA"}
    response = api_client.put("/api/users/2", data=json.dumps(payload))
    assert response.status == 200
    assert response.json()["name"] == "Updated Name"

def test_delete_user(api_client: APIRequestContext):
    response = api_client.delete("/api/users/2")
    assert response.status == 204
```

### ✅ Deliverable
- Full CRUD API test coverage. Add a test that calls the API to get a token, then uses that token as a header in subsequent requests.

---

## Task 10 — Visual Testing & Screenshots

**🎯 Goal:** Implement screenshot-based visual regression testing to catch unintended UI changes.

### Concepts Covered
- `page.screenshot()` — full page, element, clip region
- `expect(page).to_have_screenshot()` — snapshot testing
- `locator.screenshot()` — component-level screenshot
- Updating snapshots: `pytest --update-snapshots`
- Masking dynamic regions: `mask=[locator]`

### Your Task

Create `tests/test_visual.py`:

```python
import pytest
from playwright.sync_api import Page, expect

def test_login_page_visual(page: Page):
    """Capture and compare login page screenshot."""
    page.goto("https://www.saucedemo.com")
    expect(page).to_have_screenshot("login_page.png")

def test_inventory_page_visual(logged_in_page: Page):
    """
    Compare full inventory page.
    Mask the cart badge (dynamic element) to prevent flakiness.
    """
    expect(logged_in_page).to_have_screenshot(
        "inventory_page.png",
        mask=[logged_in_page.locator(".shopping_cart_badge")],
        full_page=True
    )

def test_product_card_component_screenshot(logged_in_page: Page):
    """Screenshot a single product card component."""
    first_card = logged_in_page.locator(".inventory_item").first
    first_card.screenshot(path="screenshots/product_card.png")
    # For visual diff, you would compare with a baseline
    expect(first_card).to_have_screenshot("product_card.png")

def test_screenshot_clip_region(page: Page):
    """Capture only the header region."""
    page.goto("https://www.saucedemo.com")
    page.screenshot(
        path="screenshots/header_only.png",
        clip={"x": 0, "y": 0, "width": 1280, "height": 80}
    )
```

**Run commands:**
```bash
# First run — generates baseline snapshots
pytest tests/test_visual.py -v

# Update snapshots after intentional UI change
pytest tests/test_visual.py --update-snapshots
```

### ✅ Deliverable
- Baseline screenshots generated. Manually change a CSS element and run visual tests to see them fail. Then update snapshots.

---

## Task 11 — Multi-Browser & Parallel Testing

**🎯 Goal:** Run the entire test suite across Chromium, Firefox, and WebKit in parallel — simulating real CI environments.

### Concepts Covered
- `playwright.config.py` — centralized config
- `--browser` flag: `chromium`, `firefox`, `webkit`
- `pytest-xdist` for parallel execution: `-n auto`
- Device emulation (mobile testing)
- Viewport, locale, timezone settings
- `pytest.mark` for tagging and filtering tests

### Your Task

**`playwright.config.py`** (custom config approach)
```python
# Used to set Playwright defaults via conftest fixtures
BROWSERS = ["chromium", "firefox", "webkit"]
VIEWPORT = {"width": 1280, "height": 720}
HEADLESS = True
SLOW_MO = 0
BASE_URL = "https://www.saucedemo.com"
```

**`conftest.py`** — add browser context with device emulation
```python
import pytest
from playwright.sync_api import BrowserContext

@pytest.fixture
def mobile_context(browser) -> BrowserContext:
    """Provides an iPhone 12 mobile browser context."""
    from playwright.sync_api import sync_playwright
    iphone_12 = {
        "viewport": {"width": 390, "height": 844},
        "user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)...",
        "device_scale_factor": 3,
        "is_mobile": True,
        "has_touch": True,
    }
    context = browser.new_context(**iphone_12)
    yield context
    context.close()
```

**`tests/test_cross_browser.py`**
```python
import pytest
from playwright.sync_api import Page, expect

@pytest.mark.smoke
def test_login_on_all_browsers(page: Page):
    """This test runs on every browser specified via CLI."""
    page.goto("https://www.saucedemo.com")
    page.get_by_placeholder("Username").fill("standard_user")
    page.get_by_placeholder("Password").fill("secret_sauce")
    page.get_by_role("button", name="Login").click()
    expect(page).to_have_url("**/inventory.html")

@pytest.mark.mobile
def test_login_on_mobile(mobile_context):
    """Test login on mobile viewport."""
    page = mobile_context.new_page()
    page.goto("https://www.saucedemo.com")
    page.get_by_placeholder("Username").fill("standard_user")
    page.get_by_placeholder("Password").fill("secret_sauce")
    page.get_by_role("button", name="Login").click()
    expect(page).to_have_url("**/inventory.html")
    page.close()
```

**Run commands:**
```bash
# Run on Firefox
pytest --browser=firefox -v

# Run on all browsers
pytest --browser=chromium --browser=firefox --browser=webkit -v

# Run in parallel (4 workers)
pytest -n 4 -v

# Run only smoke tests
pytest -m smoke -v

# Run on all browsers in parallel
pytest --browser=chromium --browser=firefox --browser=webkit -n auto -v
```

### ✅ Deliverable
- All smoke-marked tests pass on Chromium, Firefox, and WebKit. Parallel run completes in under 30 seconds.

---

## Task 12 — CI/CD with GitHub Actions

**🎯 Goal:** Automate test execution in a CI/CD pipeline — the final step to an industry-standard project.

### Concepts Covered
- GitHub Actions workflow YAML
- Running Playwright in Docker-like CI environment
- Artifact upload (test reports, screenshots)
- Matrix strategy for browser/OS combinations
- Caching pip dependencies

### Your Task

Create `.github/workflows/ci.yml`:

```yaml
name: 🎭 Playwright Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 8 * * *'   # Run daily at 8AM UTC

jobs:
  test:
    name: Tests (${{ matrix.browser }})
    runs-on: ubuntu-latest

    strategy:
      fail-fast: false
      matrix:
        browser: [chromium, firefox, webkit]

    steps:
      - name: ⬇️ Checkout code
        uses: actions/checkout@v4

      - name: 🐍 Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'

      - name: 📦 Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: 🎭 Install Playwright browsers
        run: playwright install --with-deps ${{ matrix.browser }}

      - name: 🧪 Run tests
        env:
          BASE_URL: ${{ secrets.BASE_URL || 'https://www.saucedemo.com' }}
          USERNAME: ${{ secrets.TEST_USERNAME || 'standard_user' }}
          PASSWORD: ${{ secrets.TEST_PASSWORD || 'secret_sauce' }}
        run: |
          pytest tests/ \
            --browser=${{ matrix.browser }} \
            --html=reports/report_${{ matrix.browser }}.html \
            --self-contained-html \
            -v \
            --tb=short \
            -m "not visual"

      - name: 📊 Upload test reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-report-${{ matrix.browser }}
          path: reports/
          retention-days: 30

      - name: 📸 Upload screenshots on failure
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: failure-screenshots-${{ matrix.browser }}
          path: screenshots/
```

### ✅ Deliverable
- Push to GitHub → CI pipeline triggers → Tests run on all 3 browsers → Reports uploaded as artifacts → Green badges on README.

### Add status badge to README:
```markdown
![Playwright Tests](https://github.com/<username>/<repo>/actions/workflows/ci.yml/badge.svg)
```

---

## 🏆 Final Challenge — End-to-End Purchase Flow

**🎯 Goal:** Combine everything into one complete E2E test that simulates a real user purchasing a product.

```python
# tests/test_e2e_purchase.py
import pytest
from playwright.sync_api import Page, expect
from pages.login_page import LoginPage
from pages.inventory_page import InventoryPage
from pages.cart_page import CartPage
from pages.checkout_page import CheckoutPage
from utils.data_factory import DataFactory

def test_complete_purchase_flow(page: Page):
    """
    Full E2E: Login → Add items → Cart → Checkout → Confirm order.
    Uses Page Object Model + Faker test data.
    """
    fake = DataFactory()

    # Step 1: Login
    login = LoginPage(page).load()
    inventory = login.login("standard_user", "secret_sauce")

    # Step 2: Add 2 items
    inv_page = InventoryPage(page)
    inv_page.add_item_to_cart("Sauce Labs Backpack")
    inv_page.add_item_to_cart("Sauce Labs Bike Light")
    assert inv_page.get_cart_count() == 2

    # Step 3: Go to cart
    cart = inv_page.go_to_cart()
    cart_items = cart.get_cart_items()
    assert len(cart_items) == 2

    # Step 4: Checkout
    checkout = cart.proceed_to_checkout()
    checkout.fill_info(
        first_name=fake.first_name(),
        last_name=fake.last_name(),
        postal_code=fake.zip_code()
    )
    checkout.continue_checkout()

    # Step 5: Verify order summary
    expect(page.locator(".summary_total_label")).to_be_visible()
    checkout.finish()

    # Step 6: Confirm success
    expect(page.locator(".complete-header")).to_have_text(
        "Thank you for your order!"
    )
    expect(page).to_have_url("**/checkout-complete.html")
```

---

## 📊 Skills Checklist

After completing all tasks, you will have demonstrated:

- [x] Playwright installation and project setup
- [x] Browser, Context, and Page hierarchy
- [x] All locator strategies (role, text, label, placeholder, CSS, XPath)
- [x] Page Object Model design pattern
- [x] pytest fixtures (function/session/module scope)
- [x] Parametrized tests
- [x] `expect()` auto-retrying assertions
- [x] Wait strategies (no `time.sleep`!)
- [x] Dialog / Alert handling
- [x] iframe interaction
- [x] File upload and download
- [x] New tab / popup handling
- [x] Network interception and mocking
- [x] API testing with `APIRequestContext`
- [x] Visual regression testing
- [x] Multi-browser testing
- [x] Parallel test execution
- [x] Mobile/device emulation
- [x] CI/CD with GitHub Actions
- [x] HTML test reports
- [x] Environment variable management

---

## 🎤 Top Questions

| Question | Where to Point |
|----------|---------------|
| What is auto-waiting in Playwright? | Tasks 3, 6 |
| How do you handle flaky tests? | Task 6 (expect API), Task 7 |
| How do you implement POM? | Task 4 |
| What is the difference between `locator` and `find_element`? | Task 3 |
| How do you run tests in parallel? | Task 11 |
| How do you mock API calls? | Task 8 |
| How do you do visual testing? | Task 10 |
| How do you integrate with CI/CD? | Task 12 |
| What's your test data strategy? | Task 5 (DataFactory + Faker) |
| How do you handle authentication in tests? | Task 5 (storage state) |

---

## 🛠️ Useful Commands Reference

```bash
# Run all tests
pytest tests/ -v

# Run specific test file
pytest tests/test_login.py -v

# Run tests by marker
pytest -m smoke -v
pytest -m "not visual" -v

# Run headed (see browser)
pytest --headed --slowmo 800

# Run specific browser
pytest --browser=firefox -v

# Parallel execution
pytest -n auto -v

# Generate HTML report
pytest --html=reports/report.html --self-contained-html

# Update visual snapshots
pytest --update-snapshots

# Record a new test with codegen
playwright codegen https://www.saucedemo.com

# Debug mode (Playwright Inspector)
PWDEBUG=1 pytest tests/test_login.py -v

# Trace viewer (record & replay)
pytest --tracing=on
playwright show-trace test-results/trace.zip
```

---

## 📚 Resources

- [Playwright Python Docs](https://playwright.dev/python/docs/intro)
- [pytest-playwright](https://pytest-playwright.azurewebsites.net/)
- [SauceDemo (test site)](https://www.saucedemo.com)
- [The Internet (Heroku test site)](https://the-internet.herokuapp.com)
- [DemoQA](https://demoqa.com)
- [ReqRes API](https://reqres.in)

---

*Built with ❤️ for Playwright Python learners.*