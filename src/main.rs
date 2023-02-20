mod config;
mod routes;
mod util;
mod db;
mod muted;
mod newsboat_actor;

use actix::prelude::*;
use sqlx::{SqliteConnection,Connection,ConnectOptions};
use sqlx::sqlite::SqliteConnectOptions;
use actix_web::middleware::Logger;
use actix_web::{web, App, HttpServer};
use clap::Parser;
use std::{env, str::FromStr};

use crate::{
    util::{expand_tilde,get_env_key,path_exists},
    config::{DEFAULT_NEWSBOAT_BIN,Config,MOAT_KEY_ENV,DEFAULT_LOG_LEVEL},
    newsboat_actor::NewsboatActor,
    muted::Muted,
    routes::*,
};

#[derive(Parser, Debug)]
#[clap(
    version = "0.2.0",
    author = "Kafva <https://github.com/Kafva>",
    about = "moat server"
)]
struct Args {
    /// Path to newsboat executable
    #[cfg(target_os = "macos")]
    #[clap(short, long, default_value = DEFAULT_NEWSBOAT_BIN,
        value_parser = path_exists
    )]
    newsboat_bin: String,

    #[cfg(target_os = "linux")]
    #[clap(short = 'b', long, default_value = DEFAULT_NEWSBOAT_BIN,
           value_parser = path_exists)]
    newsboat_bin: String,

    /// Path to newsboat config
    #[clap(short = 'C', long, default_value = "~/.newsboat/config",
           value_parser = path_exists)]
    newsboat_config: String,

    /// Path to newsboat cache.db
    #[clap(short = 'c', long, default_value = "~/.newsboat/cache.db",
           value_parser = path_exists)]
    cache_db: String,

    /// Path to newsboat urls file
    #[clap(short, long, default_value = "~/.newsboat/urls",
           value_parser = path_exists)]
    urls: String,

    /// Address to bind to
    #[clap(short, long, default_value = "127.0.0.1", value_parser)]
    addr: String,

    /// Port to listen on
    #[clap(short, long, default_value_t = 7654)]
    port: u16
}

//============================================================================//



#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let args: Args = Args::parse();
    let urls = expand_tilde(args.urls.as_str());
    let config = Config {
           cache_db: expand_tilde(args.cache_db.as_str()),
           newsboat_config: expand_tilde(args.newsboat_config.as_str()),
           newsboat_bin: expand_tilde(args.newsboat_bin.as_str()),
           urls: urls.clone()
    };

    if env::var("RUST_LOG").unwrap_or("".to_string()) == "" {
        env::set_var("RUST_LOG", DEFAULT_LOG_LEVEL)
    }

    env_logger::builder().format_target(false).init();

    let _ = get_env_key();

    let muted = Muted::from_urls_file(&urls)?;

    let conn = if env::var("RUST_LOG").unwrap_or("".to_string()) == "debug" {
        SqliteConnection::connect(&config.cache_db).await
    } else {
        SqliteConnectOptions::from_str(&config.cache_db).unwrap()
                .disable_statement_logging().connect().await

    }.expect("Could not open database");

    let actor_addr = NewsboatActor { config, muted, conn }.start();

    moat_info!("Listening on {}:{}...", args.addr, args.port);


    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .wrap(Logger::new("%a %{User-Agent}i"))
            .app_data(web::Data::new(actor_addr.to_owned()))
            .service(reload)
            .service(feeds)
            .service(items)
            .service(unread)
    })
    .workers(2)
    .bind((args.addr, args.port))?
    .run()
    .await
}
