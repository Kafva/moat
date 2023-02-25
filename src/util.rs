use crate::MOAT_KEY_ENV;
use std::path::Path;

// Import log::error() and log::info() as println!() during
// tests so that output is shown when using cargo test -- --nocapture
#[macro_export(local_inner_macros)]
macro_rules! _moat_log {
    ($log_cmd:tt, $fmt:literal, $($x:expr),*) => {
        #[cfg(test)] {
            std::println!(std::concat!(_moat_log_prefix!(), $fmt), std::file!(), std::line!(), $($x),*);
        }
        #[cfg(not(test))] {
            log::$log_cmd!(std::concat!(_moat_log_prefix!(), $fmt), std::file!(), std::line!(), $($x),*);
        }
    };
    ($log_cmd:tt, $fmt:literal) => {
        #[cfg(test)] {
            std::println!(std::concat!(_moat_log_prefix!(), $fmt), std::file!(), std::line!());
        }
        #[cfg(not(test))] {
            log::$log_cmd!(std::concat!(_moat_log_prefix!(), $fmt), std::file!(), std::line!());
        }
    };
}

#[macro_export]
macro_rules! _moat_debug {
    ($fmt:literal, $($x:expr),*) => {
        _moat_log!(debug, $fmt, $($x),*)
    };
    ($fmt:literal) => {
        _moat_log!(debug, $fmt)
    };
}

#[macro_export(local_inner_macros)]
macro_rules! _moat_info {
    ($fmt:literal, $($x:expr),*) => {
        _moat_log!(info, $fmt, $($x),*)
    };
    ($fmt:literal) => {
        _moat_log!(info, $fmt)
    };
}

#[macro_export(local_inner_macros)]
macro_rules! _moat_error {
    ($fmt:literal, $($x:expr),*) => {
        _moat_log!(error, $fmt, $($x),*)
    };
    ($fmt:literal) => {
        _moat_log!(error, $fmt)
    };
}

#[macro_export]
macro_rules! _moat_log_prefix {
        () => {
            "\x1b[90m[\x1b[0m{}:{}\x1b[90m]\x1b[0m "
    };
}

//============================================================================//

#[macro_export(local_inner_macros)]
macro_rules! moat_debug {
    // Match a format literal + one or more expressions
    ($fmt:literal, $($x:expr),*) => {
        _moat_debug!($fmt, $($x),*);
    };
    ($fmt:literal) => {
        _moat_debug!($fmt);
    };
}

#[macro_export(local_inner_macros)]
macro_rules! moat_info {
    ($fmt:literal, $($x:expr),*) => {
        _moat_info!($fmt, $($x),*);
    };
    ($fmt:literal) => {
        _moat_info!($fmt);
    };
}

#[macro_export(local_inner_macros)]
macro_rules! moat_error {
    ($fmt:literal, $($x:expr),*) => {
        _moat_error!($fmt, $($x),*);
    };
    ($fmt:literal) => {
        _moat_error!($fmt);
    };
}

//============================================================================//

pub fn expand_tilde(value: &str) -> String {
    value.replace("~", std::env::var("HOME").unwrap().as_str())
}

pub fn get_env_key() -> String {
    let key = std::env::var(MOAT_KEY_ENV)
              .unwrap_or_else(|_| {
                  moat_error!("Missing '{}'", MOAT_KEY_ENV);
                  panic!("Error retrieving key")
              });
    if key == "" {
        moat_error!("Missing '{}'", MOAT_KEY_ENV);
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



