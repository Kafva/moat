use std::future::{ready, Ready};
use actix_web::{ 
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error,
};
use futures_util::future::LocalBoxFuture;

use crate::config::MOAT_KEY_ENV;

pub struct CheckCreds;

pub struct CheckCredsMiddleware<S> {
    service: S
}

// Middleware factory is `Transform` trait
// `S` - type of the next service
// `B` - type of response's bodys
impl<S, B> Transform<S, ServiceRequest> for CheckCreds
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = CheckCredsMiddleware<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ready(Ok(CheckCredsMiddleware { service }))
    }
}

impl<S, B> Service<ServiceRequest> for CheckCredsMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        println!("Hi from start. You requested: {}", req.path());

        let fut = self.service.call(req);

        Box::pin(async move {
            let res = fut.await?;

            println!("Hi from response");
            Ok(res)
        })
    }

    //if let Some(creds) = req.headers().get("x-creds") {
    //    if let Ok(key) = std::env::var(MOAT_KEY_ENV) {
    //        if creds.to_str().unwrap_or("") != key {
    //            return HttpResponse::Unauthorized().body("")
    //        }

    //    } else {
    //        // Should never happen
    //        return HttpResponse::Unauthorized().body("")
    //    }
    //} else {
    //    return HttpResponse::Unauthorized().body("")
    //}

}
