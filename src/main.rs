#[macro_use]
extern crate rocket;
use crate::urls_parser::get_muted;
use clap::Parser;
use rocket::{Build, Rocket};

// The `mod` keyword will expand to the contents of the file
// with the corresponding name
mod dataguards;
mod db_parser;
mod errors;
mod models;
mod routes;
mod urls_parser;
use crate::db_parser::get_feed_list;
use models::Config;
use rocket::shield::{Hsts, Shield};

#[derive(Parser, Debug)]
#[clap(
    version = "0.1.0",
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
    newsboat_path: String,

    #[cfg(target_os = "linux")]
    #[clap(short, long, default_value = "/usr/bin/newsboat", value_parser)]
    newsboat_path: String,

    /// Path to newsboat cache.db
    #[clap(short, long, default_value = "~/.newsboat/cache.db", value_parser)]
    cache_path: String,

    /// Path to newsboat urls file
    #[clap(short, long, default_value = "~/.newsboat/urls", value_parser)]
    urls_path: String,
}

fn expand_tilde(value: String) -> String {
    value.replace("~", std::env::var("HOME").unwrap().as_str())
}

// The launch attribute generates a main() function
#[launch]
fn rocket() -> Rocket<Build> {
    let opts: Args = Args::parse();

    let config = Config {
        cache_path: expand_tilde(opts.cache_path),
        newsboat_path: expand_tilde(opts.newsboat_path),
        muted_list: get_muted(expand_tilde(opts.urls_path)).unwrap(),
    };

    // Sanity check, verify that the cache.db exists and has at least one entry
    let feeds = get_feed_list(&config.cache_path, &config.muted_list);
    if feeds.is_err() || feeds.unwrap().is_empty() {
        panic!("cache.db does not exist or is empty")
    }

    // HTTP headers that should be included in all responses
    // are configured through 'Shields', here we add 'Strict-Transport-Security'
    let shield = Shield::default().enable(Hsts::default());

    // Pass the config into the global state of rocket and
    // start the server with each route mounted at '/'
    rocket::build()
        .manage(Config::from(config))
        .register(
            "/",
            catchers![
                errors::internal_error,
                errors::unauthorized,
                errors::not_found,
                errors::default
            ],
        )
        .mount(
            "/",
            routes![
                routes::feeds,
                routes::items,
                routes::reload,
                routes::unread
            ],
        )
        .attach(shield)
}
