mod config;
mod middleware;
mod routes;
mod util;

use std::path::Path;
use actix_web::middleware::Logger;
use actix_web::{web, App, HttpServer};
use clap::Parser;

use crate::{
    util::{get_muted,expand_tilde},
    config::{DEFAULT_NEWSBOAT_BIN,Config,MOAT_KEY_ENV},
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
           urls: urls.clone(),
           muted_list: get_muted(urls.as_str()).unwrap(),
    };

    env_logger::init_from_env(env_logger::Env::default()
                              .default_filter_or("info"));

    if std::env::var(MOAT_KEY_ENV).is_err() {
        log::error!("Server requires '{}' to be set", MOAT_KEY_ENV);
        // TODO exit
    }

    log::info!("Listening on {}:{}...", args.addr, args.port);

    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .wrap(Logger::new("%a %{User-Agent}i"))
            .app_data(web::Data::new(config.to_owned()))
            .service(reload)
            .service(unread)
            .service(feeds)
            .service(items)
    })
    .workers(2)
    .bind((args.addr, args.port))?
    .run()
    .await
}

//============================================================================//

fn path_exists(path_str: &str) -> Result<String,String> {
    let expanded_path = expand_tilde(path_str);
    let filepath = Path::new(expanded_path.as_str());
    
    if !filepath.is_file() {
        Err("No such file".to_string())
    } else {
        Ok(String::from(path_str))
    }
}

