mod routes;
mod util;

use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};
use clap::Parser;

use crate::{
    util::{get_muted,expand_tilde},
    routes::*,
};

// Muted list seperate from config..?

#[derive(Clone)]
pub struct Config {
    pub cache_db: String,
    pub newsboat_bin: String,
    pub newsboat_config: String,
    pub urls: String,
    pub muted_list: Vec<String>,
}

#[derive(Parser, Debug)]
#[clap(
    version = "0.2.0",
    author = "Kafva <https://github.com/Kafva>",
    about = "moat server"
)]
struct Args {
    /// Path to newsboat executable
    #[cfg(target_os = "macos")]
    #[clap(
        short,
        long,
        default_value = "/opt/homebrew/bin/newsboat",
        value_parser
    )]
    newsboat_bin: String,

    #[cfg(target_os = "linux")]
    #[clap(short = 'b', long, default_value = "/usr/bin/newsboat", value_parser)]
    newsboat_bin: String,

    /// Path to newsboat config
    #[clap(short = 'C', long, default_value = "~/.newsboat/config", value_parser)]
    newsboat_config: String,

    /// Path to newsboat cache.db
    #[clap(short = 'c', long, default_value = "~/.newsboat/cache.db", value_parser)]
    cache_db: String,

    /// Path to newsboat urls file
    #[clap(short, long, default_value = "~/.newsboat/urls", value_parser)]
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

    HttpServer::new(move || {
        App::new().app_data(web::Data::new(config.to_owned()))
            .route("/unread", web::get().to(unread))
            .route("/reload", web::get().to(reload))
            .route("/feeds", web::get().to(feeds))
            .route("/items", web::get().to(items))
    })
    .bind((args.addr, args.port))?
    .run()
    .await
}




