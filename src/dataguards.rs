use regex::Regex;
use rocket::{Request, Data, data::FromData, request::FromRequest, data::ByteUnit, http::Status};
use rocket::data;
use rocket::request;
use rocket::tokio::io::AsyncReadExt;

/// Custom type for the data of POST requests to the /read endpoint 
pub struct ReadToggleData {
    pub id: u32,
    pub read: bool
}

#[derive(Debug)]
pub enum Err {
    InvalidKey,
    MissingKey
}

/// To validate data recieved in the body of POST requests rocket relies
/// on an implementation of the `FromData` trait for the struct in question.   
///  https://api.rocket.rs/v0.5-rc/rocket/data/trait.FromData.html
#[rocket::async_trait]
impl<'r> FromData<'r> for ReadToggleData {
    type Error = Err; 
    
    async fn from_data(_req: &'r Request<'_>, data: Data<'r>) -> data::Outcome<'r, Self> {
        
        // Content exceeding 255 bytes isn't parsed
        let mut stream = data.open( "255".parse::<ByteUnit>().unwrap() );
        let mut buf = Vec::new();
        
        // Wait for the async read of the content of the body
        let _ = stream.read_to_end(&mut buf).await;
        
        // We expect the input to be on the format
        //  id=<u32>&read=<1|0>
        let id_regex    = Regex::new(r"id=(\d{1,15})").unwrap();
        let read_regex  = Regex::new(r"read=(0|1)").unwrap();
        
        let body_as_string = std::str::from_utf8(&buf)
            .expect("Failed to decode request body");
        
        data::Outcome::Success(
            ReadToggleData {
                // Pass the string-body to each regex and unwrap the
                // first capture group which holds the value for
                // each key
                id:   id_regex.captures(body_as_string).unwrap()
                    .get(1).unwrap().as_str()
                        .parse::<u32>().unwrap(),
                read: read_regex.captures(body_as_string).unwrap()
                    .get(1).unwrap().as_str()
                        .parse::<u32>().unwrap() > 0
            }
        )
    }
}


pub struct Creds<'r>(&'r str);

/// Every route with `Creds` as a parameter will hook into this data guard
/// handler which ensures that the client's request includes the secret key configured for
/// the application in the `x-creds` header
#[rocket::async_trait]
impl<'r> FromRequest<'r> for Creds<'r> {
    type Error = Err; 
    
    async fn from_request(req: &'r Request<'_>) -> request::Outcome<Self, Self::Error> {
        
        let env_key = std::env::var("REMOAT_KEY")
            .expect("No $REMOAT_KEY configured in enviroment");
        
        match req.headers().get_one("x-creds") {
            None =>
                request::Outcome::Failure( (Status::Unauthorized, Err::MissingKey) ),
            Some(key) if key == env_key => 
                request::Outcome::Success( Creds(key) ),
            Some(_) =>
                request::Outcome::Failure((Status::Unauthorized, Err::InvalidKey))
        } 
    }
}
