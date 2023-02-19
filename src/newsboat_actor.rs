use std::process::Command;
use sqlx::SqlitePool;
use actix::prelude::*;
use crate::{
    db::{RssFeed,feeds},
    config::Config
};

#[derive(Message)]
#[rtype(result = "Result<Vec<RssFeed>, sqlx::Error>")]
//#[rtype(result = "()")]
pub struct FeedsMessage;

#[derive(Message)]
#[rtype(result = "Result<std::process::ExitStatus, std::io::Error>")]
pub struct ReloadMessage;

//============================================================================//

pub struct NewsboatActor {
    pub config: Config,
    pub pool: SqlitePool
}

// Provide Actor implementation for our actor
impl Actor for NewsboatActor {
    type Context = Context<Self>;

    fn started(&mut self, _ctx: &mut Context<Self>) {
       log::info!("Actor is alive");
    }

    fn stopped(&mut self, _ctx: &mut Context<Self>) {
       log::info!("Actor is stopped");
    }
}

//============================================================================//

impl Handler<FeedsMessage> for NewsboatActor {
    type Result = Result<Vec<RssFeed>, sqlx::Error>;
    //type Result = ();

    fn handle(&mut self, msg: FeedsMessage, ctx: &mut Context<Self>) -> Self::Result {
       //let executor = async {
       //     feeds(&self.pool).await
       //};
       //ctx.spawn(executor);
       //let fut = Box::pin(async {
       //      feeds(&self.pool).await;
       //});

       //let fut = feeds(&self.pool).into_actor(self);
       //let actor_fut = fut.into_actor(self);
       
       //ctx.wait(fut);

       //ctx.spawn()
       //
       //let x = actix_web::rt::System::current().to_owned
       
       let x = futures::executor::block_on(feeds(&self.pool));
       log::info!("{:#?}", x);


       //let out = actix_web::rt::Runtime::block_on(|| feeds(&self.pool) );
       //let x = actix_web::rt::System::new().block_on( feeds(&self.pool) );
       //let pool = self.pool.clone();
       //let _x = actix_web::web::block( move || async {
       //     feeds(pool).await
       //});
       //log::info!("xd {:#?}", x);

       //let actor_fut = _x.into_actor(self);
       //ctx.wait(actor_fut);


       //let fut = Box::pin(async {
       //    //feeds(&self.pool).await;
       //    println!("Easy task done!");
       //});

       //let actor_future = fut.into_actor(self);

       //// Still using `wait` here.
       //ctx.wait(actor_future);
       Ok(vec![ RssFeed::default() ])
    }
}


impl Handler<ReloadMessage> for NewsboatActor {
    type Result = Result<std::process::ExitStatus, std::io::Error>;

    fn handle(&mut self, _: ReloadMessage, _: &mut Context<Self>) -> Self::Result {
        Command::new(self.config.newsboat_bin.as_str())
            .arg("-C")
            .arg(self.config.newsboat_config.as_str())
            .arg("-c")
            .arg(self.config.cache_db.as_str())
            .arg("-u")
            .arg(self.config.urls.as_str())
            .arg("-x")
            .arg("reload")
            .status()
    }
}

