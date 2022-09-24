#[macro_use] extern crate rocket;
use rocket::{Rocket, Build};
use clap::Parser;
use crate::urls_parser::get_muted;

// The `mod` keyword will expand to the contents of the file
// with the corresponding name
mod routes;
mod models;
mod dataguards;
mod errors;
mod db_parser;
mod urls_parser;
use models::Config;
use rocket::shield::{Shield, Hsts};

#[derive(Parser, Debug)]
#[clap(version = "0.1.0", author = "Kafva <https://github.com/Kafva>",
  about = "moat server")]
struct Args {
    /// Path to newsboat executable
    #[cfg(target_os = "macos")]
    #[clap(short, long, default_value = "/opt/homebrew/bin/newsboat", value_parser)]
    newsboat_path: String,

    #[cfg(target_os = "linux")]
    #[clap(short, long, default_value = "/usr/bin/newsboat", value_parser)]
    newsboat_path: String,

    /// Path to newsboat cache.db
    #[clap(short, long, default_value = "~/.newsboat/cache.db", value_parser)]
    cache_path: String,

    /// Path to newsboat urls file
    #[clap(short, long, default_value = "~/.newsboat/urls", value_parser)]
    urls_path: String
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

    // HTTP headers that should be included in all responses
    // are configured through 'Shields', here we add 'Strict-Transport-Security'
    let shield = Shield::default().enable(Hsts::default());

    // Pass the config into the global state of rocket and
    // start the server with each route mounted at '/'
    rocket::build()
        .manage(Config::from(config))
        .register("/", catchers![
            errors::internal_error,
            errors::unauthorized,
            errors::not_found,
            errors::default
        ])
        .mount("/", routes![
        routes::feeds,
        routes::items,
        routes::reload,
        routes::unread
    ])
    .attach(shield)
}
