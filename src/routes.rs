use actix_web::{patch, get, web, HttpResponse, HttpRequest, Responder};
use super::Config;
use std::process::Command;

pub const ERR_RESPONSE: &'static str = "{ \"success\": false }";
pub const OK_RESPONSE: &'static str = "{ \"success\": true }";

// Endpoints will not return 415 when the wrong method is provided
//  https://github.com/actix/actix-web/issues/2735

#[get("/unread")]
pub async fn unread(
    _req_body: String
) -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

#[patch("/reload")]
pub async fn reload(config: web::Data<Config>) -> impl Responder {
    let output = Command::new(config.newsboat_bin.as_str())
        .arg("-C")
        .arg(config.newsboat_config.as_str())
        .arg("-c")
        .arg(config.cache_db.as_str())
        .arg("-u")
        .arg(config.urls.as_str())
        .arg("-x")
        .arg("reload")
        .output()
        .expect("Reload failed");

    if output.stderr.len() == 0 && 
       output.stdout.len() == 0 {
        HttpResponse::Ok().body(OK_RESPONSE)
    } else {
        HttpResponse::InternalServerError().body(ERR_RESPONSE)
    }
}

#[get("/feeds")]
pub async fn feeds() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

#[get("/items")]
pub async fn items() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

