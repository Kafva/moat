use regex::Regex;
use rocket::{Request, Data, data::FromData, request::FromRequest, data::ByteUnit, http::Status};
use rocket::data;
use rocket::request;
use rocket::tokio::io::AsyncReadExt;

/// Custom type for the data of POST requests to the /read endpoint
pub struct ReadToggleData {
    pub id: u32,
    pub unread: bool
}

#[derive(Debug)]
pub enum KeyErr <'a> {
    InvalidKey(&'a str),
    RegexCaptureFailure(&'a str),
    MissingKey(&'a str),
    UnparsableValueForKey(&'a str)
}

impl std::fmt::Display for KeyErr <'_> {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match *self {
            KeyErr::InvalidKey(key) =>
                write!(f, "Invalid key '{}'", key),
            KeyErr::MissingKey(key) =>
                write!(f, "Missing key '{}'", key),
            KeyErr::UnparsableValueForKey(key) =>
                write!(f, "Unable to parse vaue for key '{}'", key),
            KeyErr::RegexCaptureFailure(key) =>
                write!(f, "Unable to capture value for key: '{}'", key),
        }
    }
}

/// Extracts the value for a specific key in a urlencoded form based on a provided regex 
/// The value needs to be a generic type <T> which can be parsed from a string
fn get_value_for_key<'a,T: std::str::FromStr>(key: &'a str, body_as_string: &str, regex: Regex) -> Result<T,KeyErr<'a> > {

    // Pass the string-body to each regex and unwrap the
    // first capture group which holds the value for
    // each key
    match regex.captures(body_as_string) {
        Some(c) => {
            match c.get(1) {
                Some(c) => {
                    match c.as_str().parse::<T>() {
                        Ok(c) => return Ok(c),
                        Err(_) => return Err( KeyErr::UnparsableValueForKey(key) )
                    }
                }
                None => return Err( KeyErr::RegexCaptureFailure(key) )
            }
        }
        None => return Err( KeyErr::RegexCaptureFailure(key) )
    }
}

/// To validate data recieved in the body of POST requests rocket relies
/// on an implementation of the `FromData` trait for the struct in question.
///  https://api.rocket.rs/v0.5-rc/rocket/data/trait.FromData.html
#[rocket::async_trait]
impl<'r> FromData<'r> for ReadToggleData {
    type Error = KeyErr<'r>;

    async fn from_data(_req: &'r Request<'_>, data: Data<'r>) -> data::Outcome<'r, Self> {

        // Content exceeding 255 bytes isn't parsed
        let mut stream = data.open( "255".parse::<ByteUnit>().unwrap() );
        let mut buf = Vec::new();

        // Wait for the async read of the content of the body
        let _ = stream.read_to_end(&mut buf).await;

        // We expect the input to be on the format
        //  id=<u32>&unread=<1|0>
        let id_regex      = Regex::new(r"id=(\d{1,15})").unwrap();
        let unread_regex  = Regex::new(r"unread=(true|false)").unwrap();

        let body_as_string = std::str::from_utf8(&buf)
            .expect("Failed to decode request body");

        match get_value_for_key::<u32>("id", body_as_string, id_regex) {

            Ok(id) => match get_value_for_key::<bool>("unread", body_as_string, unread_regex) {

                Ok(unread) => data::Outcome::Success(
                    ReadToggleData {
                        id: id,
                        unread: unread
                    }
                ),
                Err(e) => data::Outcome::Failure( (Status::BadRequest, e) ) 
            },
            Err(e) => data::Outcome::Failure( (Status::BadRequest, e) )
        }
    }
}


pub struct Creds<'r>(&'r str);

/// Every route with `Creds` as a parameter will hook into this data guard
/// handler which ensures that the client's request includes the secret key configured for
/// the application in the `x-creds` header
#[rocket::async_trait]
impl<'r> FromRequest<'r> for Creds<'r> {
    type Error = KeyErr<'r>;

    async fn from_request(req: &'r Request<'_>) -> request::Outcome<Self, Self::Error> {

        let env_key = std::env::var("REMOAT_KEY")
            .expect("No $REMOAT_KEY configured in enviroment");

        match req.headers().get_one("x-creds") {
            None =>
                request::Outcome::Failure( (Status::Unauthorized, KeyErr::MissingKey("x-creds")  ) ),
            Some(key) if key == env_key =>
                request::Outcome::Success( Creds(key) ),
            Some(_) =>
                request::Outcome::Failure((Status::Unauthorized, KeyErr::InvalidKey("x-creds") ))
        }
    }
}
