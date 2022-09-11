#[macro_use] extern crate rocket;
extern crate clap;
use rocket::Rocket;
use rocket::Build;
use clap::{AppSettings, Clap};

//mod db_parser;

// The `mod` keyword will expand to the contents of the file
// with the corresponding name
mod routes; 

/*** Testing ***/

/// More information? 
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

    // Gets a value for config if supplied by user, or defaults to "./conf/server.conf"
    println!("Value for config: {}", opts.config);

    // Start the server
    rocket::build().mount("/", routes![routes::index])
}
