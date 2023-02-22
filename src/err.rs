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
    DecodeError(base64::DecodeError)
}

//============================================================================//

impl actix_web::error::ResponseError for MoatError {
    fn error_response(&self) -> HttpResponse {
        HttpResponse::build(self.status_code())
            .insert_header(ContentType::html())
            .body(self.to_string())
    }

    fn status_code(&self) -> StatusCode {
        match *self {
            MoatError::SqlError(..) => StatusCode::INTERNAL_SERVER_ERROR,
            MoatError::DecodeError(..) => StatusCode::BAD_REQUEST,
        }
    }
}

//============================================================================//

impl fmt::Display for MoatError {
   fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            MoatError::SqlError(..) =>
                f.write_str("SQL query error"),
            MoatError::DecodeError(..) =>
                f.write_str("base64 decoding error"),
        }
   }
}

impl error::Error for MoatError {
    fn source(&self) -> Option<&(dyn error::Error + 'static)> {
        match *self {
            MoatError::SqlError(ref e) => Some(e),
            MoatError::DecodeError(ref e) => Some(e),
        }
    }
}

impl From<base64::DecodeError> for MoatError {
    fn from(err: base64::DecodeError) -> MoatError {
        MoatError::DecodeError(err)
    }
}

impl From<sqlx::Error> for MoatError {
    fn from(err: sqlx::Error) -> MoatError {
        MoatError::SqlError(err)
    }
}
