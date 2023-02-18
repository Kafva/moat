use actix_web::{patch, web, HttpResponse, HttpRequest, Responder};
use super::Config;
use std::process::Command;
use crate::config::MOAT_KEY_ENV;

pub const ERR_RESPONSE: &'static str = "{ \"success\": false }";
pub const OK_RESPONSE: &'static str = "{ \"success\": true }";

// Endpoints will not return 415 when the wrong method is provided
//  https://github.com/actix/actix-web/issues/2735

pub async fn unread(
    _req_body: String
) -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

#[patch("/reload")]
pub async fn reload(config: web::Data<Config>, req: HttpRequest) -> impl Responder {
    // 1. Check creds header

    if let Some(creds) = req.headers().get("x-creds") {
        if let Ok(key) = std::env::var(MOAT_KEY_ENV) {
            if creds.to_str().unwrap_or("") != key {
                return HttpResponse::Unauthorized().body("")
            }

        } else {
            // Should never happen
            return HttpResponse::Unauthorized().body("")
        }
    } else {
        return HttpResponse::Unauthorized().body("")
    }

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

pub async fn feeds() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

pub async fn items() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

