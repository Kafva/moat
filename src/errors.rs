use rocket::Request;
use rocket::http::Status;

pub const ERR_RESPONSE: &'static str = "{ \"success\": false }";
pub const OK_RESPONSE: &'static  str = "{ \"success\": true }";

#[catch(500)]
pub fn internal_error() -> &'static str {
    ERR_RESPONSE
}

#[catch(401)]
pub fn unauthorized(_req: &Request) -> &'static str {
    "{ \"success\": false, \"message\": \"Unauthorized\" }"
}

#[catch(404)]
pub fn not_found(_req: &Request) -> &'static str {
    "{ \"success\": false, \"message\": \"Not found\" }"
}

#[catch(default)]
pub fn default(_status: Status, _req: &Request) -> &'static str {
    ERR_RESPONSE
}
