use rocket::Request;
use rocket::http::Status;

#[catch(500)]
pub fn internal_error() -> &'static str {
    "{ \"success\": false }"
}

#[catch(404)]
pub fn not_found(_req: &Request) -> &'static str {
    "{ \"success\": false }"
}

#[catch(default)]
pub fn default(_status: Status, _req: &Request) -> &'static str {
    "{ \"success\": false }"
}
