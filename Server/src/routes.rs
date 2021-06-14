
#[get("/")]
pub fn index() -> &'static str {
    "Static lifetime text"
}
