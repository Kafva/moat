use rocket::Request;
use rocket::http::Status;

#[catch(500)]
pub fn internal_error() -> &'static str {
    "Internal Server error"
}

#[catch(404)]
pub fn not_found(req: &Request) -> String {
    format!("Not found: {}", req.uri())
}

#[catch(default)]
pub fn default(status: Status, req: &Request) -> String {
    format!("{} ({})", status, req.uri())
}
