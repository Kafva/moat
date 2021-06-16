#[macro_use] extern crate rocket;
extern crate clap;
use rocket::{Rocket, Build};
use clap::{AppSettings, Clap};

// The `mod` keyword will expand to the contents of the file
// with the corresponding name
mod routes;
mod models;
mod dataguards;
mod errors;
mod config_parser;
mod db_parser;
use models::Config;
use config_parser::get_config;

/// Server 
#[derive(Clap)]
#[clap(version = "1.0", author = "Kafva <https://github.com/Kafva>")]
#[clap(setting = AppSettings::ColoredHelp)]
struct Opts {
    /// Sets a custom config file
    #[clap(short, long, default_value = "./conf/server.conf")]
    config: String,
}

// The launch attribute generates a main() function 
#[launch]
fn rocket() -> Rocket<Build> {
    
    let opts: Opts = Opts::parse();
    
    let config: Config = 
        get_config(&opts.config.to_string()).unwrap();
    
    // Pass the config into the models state of rocket and
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
        routes::read
    ])
}
