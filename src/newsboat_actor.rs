use super::moat_info;
use crate::Muted;
use std::process::Command;
use sqlx::SqliteConnection;
use actix::prelude::*;
use crate::{
    db::{RssFeed,feeds},
    config::Config
};

#[derive(Message)]
#[rtype(result = "Result<Vec<RssFeed>, sqlx::Error>")]
pub struct FeedsMessage;

#[derive(Message)]
#[rtype(result = "Result<std::process::ExitStatus, std::io::Error>")]
pub struct ReloadMessage;

//============================================================================//

pub struct NewsboatActor {
    pub config: Config,
    pub muted: Muted,
    pub conn: SqliteConnection,
}

// Provide Actor implementation for our actor
impl Actor for NewsboatActor {
    type Context = Context<Self>;

    fn started(&mut self, _ctx: &mut Context<Self>) {
       //moat_info!("Actor started...");
    }

    fn stopped(&mut self, _ctx: &mut Context<Self>) {
       //moat_info!("Actor stopped...");
    }
}

//============================================================================//

impl Handler<FeedsMessage> for NewsboatActor {
    type Result = Result<Vec<RssFeed>, sqlx::Error>;

    fn handle(&mut self, _: FeedsMessage, _: &mut Context<Self>) -> Self::Result {
       // This is the only way I found for executing an async task in the
       // handler for an actor...
       futures::executor::block_on(feeds(&mut self.conn, &self.muted))
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

