use actix_web::{web, HttpResponse, Responder};
use super::Config;
use std::process::Command;

pub const ERR_RESPONSE: &'static str = "{ \"success\": false }";
pub const OK_RESPONSE: &'static str = "{ \"success\": true }";


pub async fn unread(
    _req_body: String
) -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

pub async fn reload(config: web::Data<Config>) -> impl Responder {
    // 1. Check creds header
    // 2. check method or decorator?


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
        OK_RESPONSE
    } else {
        ERR_RESPONSE
    }
}

pub async fn feeds() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

pub async fn items() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

