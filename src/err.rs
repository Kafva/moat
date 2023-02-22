use actix_web::{
    HttpResponse,
    http::{
        StatusCode,
        header::ContentType
    }
};
use std::{error,fmt};

/// Enumeration of all possible errors for the endpoints of the application.
/// Having this as the return type on endpoints allows us to use '?'
/// for error handling since we implement a `From` conversion for each error
/// type.
/// There are crates that will generate the `From`, `Error` and `Display`
/// boilerplate with #[derive()].
#[derive(Debug)]
pub enum MoatError {
    SqlError(sqlx::Error),
    Base64Error(base64::DecodeError),
    Utf8Error(std::string::FromUtf8Error),
    ActorError(actix::MailboxError)
}


//============================================================================//

impl actix_web::error::ResponseError for MoatError {
    fn error_response(&self) -> HttpResponse {
        HttpResponse::build(self.status_code())
            .insert_header(ContentType::json())
            .body(self.to_string())
    }

    fn status_code(&self) -> StatusCode {
        use MoatError::*;
        match *self {
            SqlError(..) => StatusCode::INTERNAL_SERVER_ERROR,
            Base64Error(..) => StatusCode::BAD_REQUEST,
            Utf8Error(..) => StatusCode::BAD_REQUEST,
            ActorError(..) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

//============================================================================//

impl fmt::Display for MoatError {
   fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // TODO return JSON
        use MoatError::*;
        match *self {
            SqlError(..) => f.write_str("SQL query error"),
            Base64Error(..) => f.write_str("base64 decoding error"),
            Utf8Error(..) => f.write_str("utf8 decoding error"),
            ActorError(..) => f.write_str("internal messaging error"),
        }
   }
}

impl error::Error for MoatError {
    fn source(&self) -> Option<&(dyn error::Error + 'static)> {
        use MoatError::*;
        match *self {
            SqlError(ref e) => Some(e),
            Base64Error(ref e) => Some(e),
            Utf8Error(ref e) => Some(e),
            ActorError(ref e) => Some(e),
        }
    }
}

impl From<base64::DecodeError> for MoatError {
    fn from(err: base64::DecodeError) -> MoatError {
        MoatError::Base64Error(err)
    }
}

impl From<sqlx::Error> for MoatError {
    fn from(err: sqlx::Error) -> MoatError {
        MoatError::SqlError(err)
    }
}

impl From<actix::MailboxError> for MoatError {
    fn from(err: actix::MailboxError) -> MoatError {
        MoatError::ActorError(err)
    }
}

impl From<std::string::FromUtf8Error> for MoatError {
    fn from(err: std::string::FromUtf8Error) -> MoatError {
        MoatError::Utf8Error(err)
    }
}
