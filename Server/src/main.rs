#[macro_use] extern crate rocket;
use tokio::runtime::Runtime;

#[get("/")]
fn index() -> &'static str {
    "Hello, server"
}

#[launch]
fn rocket() -> _ {
    Runtime::new()
        .expect("Failed to create Tokio runtime")
        .block_on(rocket::build().mount("/", routes![index]));
    
}
