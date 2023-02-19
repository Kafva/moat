use crate::MOAT_KEY_ENV;

pub fn expand_tilde(value: &str) -> String {
    value.replace("~", std::env::var("HOME").unwrap().as_str())
}

pub fn get_env_key() -> String {
    let key = std::env::var(MOAT_KEY_ENV)
              .unwrap_or_else(|_| {
                  log::error!("Missing '{}'", MOAT_KEY_ENV);
                  panic!("Error retrieving key") 
              });
    if key == "" {
        log::error!("Missing '{}'", MOAT_KEY_ENV);
        panic!("Key is unset")
    }
    key
}

#[macro_export]
macro_rules! moat_log {
    // Match a format literal + one or more expressions
    ($fmt:literal, $($x:expr),*) => {
        log::info!(concat!("\x1b[90m[\x1b[0m{}:{}\x1b[90m]\x1b[0m ", $fmt),
                   file!(), line!(), $($x),*);
    };
    ($fmt:literal) => {
        log::info!(concat!("\x1b[90m[\x1b[0m{}:{}\x1b[90m]\x1b[0m ", $fmt),
                   file!(), line!());
    };
}
