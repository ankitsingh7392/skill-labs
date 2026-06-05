package flipkart;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import java.time.Duration;

public class FirstExample {

    @DataProvider(name = "urlList")
    public Object[][] urlList(){

        return new Object[][] {
                {"Google", "www.google.com"},
                {"Facebook", "www.facebook.com"},
                {"Yahoo", "www.yahoo.com"},
                {"instagram", "www.instagram.com"}
        };
    }

    @BeforeClass
    public void launchBrowser() {
        System.out.println("Hello TestNG!");
        WebDriver driver = new ChromeDriver();
        driver.get("https://www.selenium.dev/selenium/web/web-form.html");
        driver.manage().timeouts().implicitlyWait(Duration.ofMillis(500));
        WebElement element = driver.findElement(By.name("my-text"));
        driver.quit();



    }

    @Test(dataProvider = "urlList")
    public void MyFirstTest(String name, String url) {
        System.out.println("Hello Test!");
        System.out.println("Website Name"+ name);
        System.out.println("Website URL"+ url);
    }


    @AfterClass
    public void cleanUp() {
        System.out.println("clean up completed...");
    }

}
