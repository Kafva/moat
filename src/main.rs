mod config;
mod routes;
mod util;
mod macros;
mod db;
mod muted;
mod newsboat_actor;
mod err;

use actix::prelude::*;
use sqlx::{SqliteConnection,Connection,ConnectOptions};
use sqlx::sqlite::SqliteConnectOptions;
use actix_web::middleware::Logger;
use actix_web::{web, App, HttpServer};
use clap::Parser;
use std::{env, 
  str::FromStr,
};

use crate::{
    util::{expand_tilde,get_env_key,path_exists,get_tls_config},
    config::{DEFAULT_NEWSBOAT_BIN,Config,MOAT_KEY_ENV,DEFAULT_LOG_LEVEL},
    newsboat_actor::NewsboatActor,
    muted::Muted,
    routes::*,
    err::MoatError,
};


#[derive(Parser, Debug)]
#[clap(
    version = "0.2.0",
    author = "Kafva <https://github.com/Kafva>",
    about = "A pre-shared key needs to be set in `MOAT_KEY` on launch, the client application needs to supply the same value in its configuration after being installed."
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
    port: u16,

    /// Directory with cert.pem and key.pem to use for TLS.
    #[clap(short = 's', long, value_parser)]
    tls_dir: Option<String>,

    /// Number of workers
    #[clap(short, long, default_value_t = 2)]
    workers: usize
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

    // Ensure that MOAT_KEY_ENV is set.
    let _ = get_env_key();

    // The server needs to be restarted for changes in `urls` to be applied.
    let muted = Muted::from_urls_file(&urls)?;

    let conn = if env::var("RUST_LOG").unwrap_or("".to_string()) == "debug" {
        SqliteConnection::connect(&config.cache_db).await
    } else {
        SqliteConnectOptions::from_str(&config.cache_db).unwrap()
                .disable_statement_logging().connect().await
    }.expect("Could not open database");

    let actor_addr = NewsboatActor { config, muted, conn }.start();

    let server = HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .app_data(web::Data::new(actor_addr.to_owned()))
            .app_data(web::FormConfig::default().error_handler(|err, _| {
                // Return custom error on failed form validation
                MoatError::FormError(err).into()
            }))
            .service(reload)
            .service(feeds)
            .service(items)
            .service(update)
    })
    .workers(args.workers);

    if args.tls_dir.is_some() {
        let tls_config = get_tls_config(args.tls_dir.unwrap());
        moat_info!("Listening on https://{}:{}...", args.addr, args.port);
        server.bind_rustls((args.addr,args.port), tls_config)?.run().await

    } else {
        moat_info!("Listening on http://{}:{}...", args.addr, args.port);
        server.bind((args.addr, args.port))?.run().await
    }
}
