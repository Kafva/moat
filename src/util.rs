use crate::MOAT_KEY_ENV;
use std::path::Path;

// Import log::error() and log::info() as println!() during
// tests so that output is shown when using cargo test -- --nocapture

//#[macro_export]
//macro_rules! use_log_error {
//    () => {
//        #[cfg(test)]
//        use std::{println as error};
//
//        #[cfg(not(test))]
//        use log::error;
//    }
//}
//
//#[macro_export]
//macro_rules! use_log_info {
//    () => {
//        #[cfg(test)]
//        use std::{println as info};
//
//        #[cfg(not(test))]
//        use log::info;
//    }
//}

#[macro_export]
macro_rules! moat_log_prefix {
    () => {
        "\x1b[90m[\x1b[0m{}:{}\x1b[90m]\x1b[0m "
    };
}

// TODO insert println here during [cfg(test)]
#[macro_export]
macro_rules! moat_debug {
    // Match a format literal + one or more expressions
    ($fmt:literal, $($x:expr),*) => {
        log::debug!(concat!(moat_log_prefix!(), $fmt),
                   file!(), line!(), $($x),*);
    };
    ($fmt:literal) => {
        log::debug!(concat!(moat_log_prefix!(), $fmt),
                   file!(), line!());
    };
}

#[macro_export]
macro_rules! moat_info {
    ($fmt:literal, $($x:expr),*) => {
        log::info!(concat!(moat_log_prefix!(), $fmt),
                   file!(), line!(), $($x),*);
    };
    ($fmt:literal) => {
        log::info!(concat!(moat_log_prefix!(), $fmt),
                   file!(), line!());
    };
}

#[macro_export]
macro_rules! moat_err {
    ($fmt:literal, $($x:expr),*) => {
        log::error!(concat!(moat_log_prefix!(), $fmt),
                   file!(), line!(), $($x),*);
    };
    ($fmt:literal) => {
        log::error!(concat!(moat_log_prefix!(), $fmt),
                   file!(), line!());
    };
}

//============================================================================//

pub fn expand_tilde(value: &str) -> String {
    value.replace("~", std::env::var("HOME").unwrap().as_str())
}

pub fn get_env_key() -> String {
    let key = std::env::var(MOAT_KEY_ENV)
              .unwrap_or_else(|_| {
                  moat_err!("Missing '{}'", MOAT_KEY_ENV);
                  panic!("Error retrieving key")
              });
    if key == "" {
        moat_err!("Missing '{}'", MOAT_KEY_ENV);
        panic!("Key is unset")
    }
    key
}

pub fn path_exists(path_str: &str) -> Result<String,String> {
    let expanded_path = expand_tilde(path_str);
    let filepath = Path::new(expanded_path.as_str());

    if !filepath.is_file() {
        Err("No such file".to_string())
    } else {
        Ok(String::from(path_str))
    }
}

//============================================================================//

#[cfg(test)]
pub fn run_setup_script() {
    std::process::Command::new("./scripts/test_setup.sh").output()
        .expect("Test setup failed");
}



