use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};

pub async fn unread(
    _req_body: String
) -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

pub async fn reload() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

pub async fn feeds() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

pub async fn items() -> impl Responder {
    HttpResponse::Ok().body("TODO")
}

