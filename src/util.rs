use crate::MOAT_KEY_ENV;
use std::{
    fs::File,
    io::{prelude::*, BufReader},
};

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

/// Extract a list of all muted feeds from the provided ~/.newsboat/urls file
/// Each line is expected to follow this format:
///   <rss url>  <display url>    <tag> <name>
/// Names that start with '!' are muted and the corresponding <rss url> will be
/// part of the output vector.
/// Except for the <name>, no fields are allowed to contain blankspace.
pub fn get_muted(urls_path: &str) -> Result<Vec<String>, std::io::Error> {
    let mut muted: Vec<String> = Vec::new();
    let file = File::open(urls_path)?;

    for line in BufReader::new(file).lines() {
        let line = line.unwrap();
        if line.trim().starts_with("http") {
            let fields: Vec<&str> = line.split_whitespace().collect();

            let last_field = fields.get(3).expect("error parsing urls file");
            if last_field.trim_matches('"').starts_with("!") {
                let rssurl = fields.get(0).expect("error parsing urls file");
                let muted_entry = String::from(*rssurl);
                muted.push(muted_entry);
            }
        }
    }

    return Ok(muted);
}

//============================================================================//
#[cfg(test)]
mod tests {
    use crate::util::{get_muted,expand_tilde};
    use std::fs::File;

    fn setup() {
        std::process::Command::new("./scripts/test_setup.sh").output()
            .expect("Test setup failed");
    }


    /// To see stdout of tests:
    ///  cargo test -- --nocapture
    #[test]
    fn test_get_muted() {
        setup();
        let muted_path = expand_tilde("/tmp/moat/urls");
        let muted = get_muted(&muted_path).unwrap();
        assert!(muted.into_iter().count() > 0);

        let _ = File::create("/tmp/empty");
        let muted = get_muted("/tmp/empty").unwrap();
        assert!(muted.into_iter().count() == 0);
    }
}


