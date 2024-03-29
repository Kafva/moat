use super::moat_info;
use crate::Muted;
use std::process::Command;
use actix::prelude::*;
use crate::{
    db::{RssFeed,RssItem,Db},
    config::Config,
    err::MoatError,
};
use base64::{Engine as _, engine::general_purpose};

#[derive(Message, serde::Deserialize, Debug)]
#[cfg_attr(test, derive(serde::Serialize))]
#[rtype(result = "Result<bool, MoatError>")]
pub struct UpdateMessage {
    pub unread: bool,

    #[serde(skip_serializing_if = "Option::is_none")]
    pub id: Option<u32>,

    #[serde(skip_serializing_if = "Option::is_none")]
    pub feedurl: Option<String>,
}

#[derive(Message)]
#[rtype(result = "Result<Vec<RssFeed>, sqlx::Error>")]
pub struct FeedsMessage;

#[derive(Message)]
#[rtype(result = "Result<std::process::ExitStatus, std::io::Error>")]
pub struct ReloadMessage;

#[derive(Message)]
#[rtype(result = "Result<Vec<RssItem>, sqlx::Error>")]
pub struct ItemsMessage {
    pub rssurl: String
}


//============================================================================//

pub struct NewsboatActor {
    pub config: Config,
    pub muted: Muted,
    pub db: Db
}

impl NewsboatActor {
    pub async fn from_config(config: &Config) -> Result<Self,std::io::Error> {
        Ok(Self {
             config: config.clone(),
             muted: Muted::from_urls_file(&config.urls)?,
             db: Db::new(config.cache_db.clone())
        })
    }
}

// Provide Actor implementation for our actor
impl Actor for NewsboatActor {
    type Context = Context<Self>;

    fn started(&mut self, _ctx: &mut Context<Self>) {
       moat_info!("Actor started...");
    }

    fn stopped(&mut self, _ctx: &mut Context<Self>) {
       moat_info!("Actor stopped...");
    }
}

//============================================================================//
impl Handler<UpdateMessage> for NewsboatActor {
    type Result = Result<bool, MoatError>;

    fn handle(&mut self, msg: UpdateMessage, _: &mut Context<Self>) -> Self::Result {
        if let Some(id) = msg.id {
            let changed = futures::executor::block_on(self.db.update_item(id, msg.unread))?;
            Ok(changed)
        }
        else if let Some(feedurl) = msg.feedurl {
            let feedurl = general_purpose::STANDARD.decode(feedurl)?;
            let feedurl = String::from_utf8(feedurl)?;
            let changed = futures::executor::block_on(self.db.update_feed(feedurl, msg.unread))?;
            Ok(changed)

        } else {
            Ok(false)
        }
    }
}

impl Handler<FeedsMessage> for NewsboatActor {
    type Result = Result<Vec<RssFeed>, sqlx::Error>;

    fn handle(&mut self, _: FeedsMessage, _: &mut Context<Self>) -> Self::Result {
       // This is the only way I found for executing an async task in the
       // handler for an actor...
       futures::executor::block_on(self.db.feeds(&self.muted))
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

impl Handler<ItemsMessage> for NewsboatActor {
    type Result = Result<Vec<RssItem>, sqlx::Error>;

    fn handle(&mut self, msg: ItemsMessage, _: &mut Context<Self>) -> Self::Result {
       futures::executor::block_on(self.db.items(msg.rssurl))
    }
}
